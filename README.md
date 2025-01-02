# AO Entropy Pool: /dev/urandom in AO
AO Entropy Pool is based on [/dev/urandom](https://en.wikipedia.org/wiki//dev/random), a CSPRNG (Cryptographically secure pseudorandom number generator), in [AO](https://ao.arweave.dev).

Verifiable and deterministic generator, but extremely unpredictable.

## Index
- [How it works?](#how-it-works)
- [Documentation](#documentation)
- [Contribute](#contribute)

## How it works?
**AO Entropy Pool** implements a circular pool of 8192 bytes. Every time an interaction occurs with the process, the "Add-Entropy" Handler is called, adding to the pool the following data from the message:
- **ID**
- **Timestamp**
- **Anchor**
- **Block**

These **4 fields** were chosen for the following reason:
- **ID**: A Hash of the message signature, by nature, hard to predict and manipulate
- **Timestamp**, **Anchor**, **Block**: not controlled by the sender (at least, not at all)

AO Entropy Pool expect to other processes interact with it, simulating /dev/urandom, where the data sent by other processes work as **noise** for the pool.

When a random number is requested, slices of the pool are extracted and applied into a hash function (which can be chosen by the requester), then the hash digests are also shuffled in the pool.

## Documentation
[Here](./docs/index.md) are the technical details about the implementation and the methods used to handle malicious users, spam, and others, while keeping the generator secure.

## Contribute
WIP