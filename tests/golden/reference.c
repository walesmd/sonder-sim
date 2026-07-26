/* tests/golden/reference.c — independent oracle for the golden vectors
 * in tests/rng_spec.lua.
 *
 * The Lua RNG in src/sonder/rng.lua is a port of splitmix64 and
 * xoshiro256** (Blackman & Vigna, public domain — see
 * https://prng.di.unimi.it/). This file is the same algorithms in C,
 * straight from the reference code, plus Sonder's stream-derivation
 * rule. The spec asserts the Lua port matches these outputs bit for
 * bit; if the two implementations agree, a transcription error in
 * either would have to be mirrored in the other to go unseen.
 *
 * Regenerate the vectors with:
 *   cc -o /tmp/sonder-ref tests/golden/reference.c && /tmp/sonder-ref
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

/* --- splitmix64 (Vigna, public domain) ------------------------------ */

static uint64_t sm_state;

static uint64_t splitmix64_next(void) {
    uint64_t z = (sm_state += 0x9e3779b97f4a7c15);
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
    return z ^ (z >> 31);
}

/* --- xoshiro256** (Blackman & Vigna, public domain) ------------------ */

static uint64_t xo_state[4];

static inline uint64_t rotl(const uint64_t x, int k) {
    return (x << k) | (x >> (64 - k));
}

static uint64_t xoshiro_next(void) {
    const uint64_t result = rotl(xo_state[1] * 5, 7) * 9;
    const uint64_t t = xo_state[1] << 17;

    xo_state[2] ^= xo_state[0];
    xo_state[3] ^= xo_state[1];
    xo_state[1] ^= xo_state[2];
    xo_state[0] ^= xo_state[3];

    xo_state[2] ^= t;
    xo_state[3] = rotl(xo_state[3], 45);

    return result;
}

/* --- Sonder's stream derivation -------------------------------------- */

/* FNV-1a 64 over the seed's 8 bytes (little-endian) then the name. */
static uint64_t stream_hash(uint64_t seed, const char *name) {
    uint64_t h = 0xcbf29ce484222325;
    for (int i = 0; i < 64; i += 8) {
        h ^= (seed >> i) & 0xff;
        h *= 0x100000001b3;
    }
    for (size_t i = 0; i < strlen(name); i++) {
        h ^= (uint8_t)name[i];
        h *= 0x100000001b3;
    }
    return h;
}

static void derive_stream(uint64_t seed, const char *name) {
    sm_state = stream_hash(seed, name);
    for (int i = 0; i < 4; i++) xo_state[i] = splitmix64_next();
}

/* --------------------------------------------------------------------- */

static void dump(const char *label, int n) {
    printf("%s\n", label);
    for (int i = 0; i < n; i++) printf("  0x%016llx\n",
        (unsigned long long)xoshiro_next());
}

int main(void) {
    printf("splitmix64, seed 1893, first 4:\n");
    sm_state = 1893;
    for (int i = 0; i < 4; i++) printf("  0x%016llx\n",
        (unsigned long long)splitmix64_next());

    printf("xoshiro256**, state {1,2,3,4}, first 5:\n");
    xo_state[0] = 1; xo_state[1] = 2; xo_state[2] = 3; xo_state[3] = 4;
    dump("", 5);

    printf("stream_hash(1893, \"market\") = 0x%016llx\n",
        (unsigned long long)stream_hash(1893, "market"));
    printf("stream_hash(1893, \"war\")    = 0x%016llx\n",
        (unsigned long long)stream_hash(1893, "war"));

    derive_stream(1893, "market");
    printf("stream (1893, \"market\") state: 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
        (unsigned long long)xo_state[0], (unsigned long long)xo_state[1],
        (unsigned long long)xo_state[2], (unsigned long long)xo_state[3]);
    dump("stream (1893, \"market\"), first 5 draws:", 5);

    derive_stream(1893, "war");
    dump("stream (1893, \"war\"), first 5 draws:", 5);

    return 0;
}
