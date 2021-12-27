# Day 19 solution explanation

There are two phases: Mapping and Transforming.
- Mapping is when each scanner is mapped with one another using the clue of 12 overlapping beacons.
- Transforming is to build the transform function for each scanner so every beacon of the scanner can be transformed into the perspective of scanner 0.

## Mapping

The goal of this stage is to produce a data structure that contains the following
- Pairs of overlapping scanners.
  - E.g., [[S0, S1], [S1, S2]] means S0 has overlapping pair with S1, and S1 with S2
- The overlapping beacon locations for each overlapping scanner pair.
  - E.g., if we have [[B1, B2], [B3, B4]] for pair [S0, S1], it means the B1 in S0 and the B3 in S1 refers to the same beacon; B2 in S0 and B4 in S1 refers to the same beacon.

In the code they are represented using arrays:
```
[
  [[overlapping scanner pair1], [mapping1 of overlapping bacons]],
  [[overlapping scanner pair2], [mapping2 of overlapping bacons]],
  …
]
```
Example
```
[
  [[S0, S1], [[B1, B2], [B3, B4]]],
  [[S1, S2], […]],
  …
]
```

This is achieved mainly by using the property that the distance between two beacons is be the same in whatever orientation and with whatever offset. The actual steps are:

1. Find all distances between any two beacons in a scanner.
2. Calculate the count of overlapping distances between two scanners.
3. If the overlapping distance count >= 66–the number of edges for 12 fully connected nodes–we declare an overlapping scanner pair.
4. With the result of (3), we can find out which beacons in one scanner map to exactly which beacon in another beacon.

Once we have the mapper figures out this relationship, we go to the next phase: transforming

## Transforming

We can build a transformer for each scanner pair using the matching beacon. Each pair has 12 overlapping beacons whose location mapping we already know. We only need 2 locations for each pair to build a function that takes a beacon location in one scanner as input, and produce the beacon location in the other scanner as the output.

When we have the pair transformers, as our goal is to map every scanner to scanner 0, our next step is to build a "pipe" of transformers that will lead every scanner back to S0.

If we have the function (S1 -> S0) to map beacons from S1 to S0, and another function (S2 -> S1) to map beacons S2 to S1, then we know how to map S2 to S0 by piping the output of (S2-> S1) to (S1 -> S0). We only need to figure out the “path” from any given scanner to S0. Using the example, that is to figure out for S1, the path should be (S1 -> S0); for S2, the path should be (S2 -> S1 -> S0)

## Then

With the transformer map, we can use it to transform every beacon of the scanners to S0, and get the answers.

We can get part 2 by feeding coordinate [0, 0, 0] to each transformer function and calculate the distance.
