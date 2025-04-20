#!/bin/bash
circom circuits/vrf.circom --r1cs --sym
snarkjs r1cs info circuits/vrf.r1cs 