#!/usr/bin/env python3

# function to add up all of the integers in two input arrays using the pynum library but throw an error if the arrays contain strings
def add_arrays(arr1, arr2):
    import pynum as pn
    if not all(isinstance(x, int) for x in arr1):
        raise ValueError("Array 1 contains a non-integer")
    if not all(isinstance(x, int) for x in arr2):
        raise ValueError("Array 2 contains a non-integer")
    return pn.add(arr1, arr2)


# function to concatenate together all the string values contained in two input arrays using the pynum library
def concat_arrays(arr1, arr2):
    import pynum as pn
    if not all(isinstance(x, str) for x in arr1):
        raise ValueError("Array 1 contains a non-string")
    if not all(isinstance(x, str) for x in arr2):
        raise ValueError("Array 2 contains a non-string")
    return pn.concat(arr1, arr2)