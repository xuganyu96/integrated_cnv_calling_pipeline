from union import union
from call import call
import pandas as pd
import numpy as np
import sys

#   Read in the compiled calls and construct a list of unions

#   Read in the tcnv file
df = pd.read_csv('./detectors_outputs/compiled/compiled_calls.tcnv',
                 sep='\t',
                 header=0,
                 dtype=str)

#   initialize list of unions
unions = []

#   Take as an argument the minimum reciprocal percentage needed to be considered
#   intersected; if no argument, or bad argument is supplied, use default 0.5
try:
    input_req_reciprocal = sys.argv[1]
    if input_req_reciprocal == "T":
        input_req_reciprocal = True
    else:
        input_req_reciprocal = False
    print("Reciprocal requirement specified to be " + str(input_req_reciprocal))
    call.require_reciprocal = input_req_reciprocal
except:
    print("[ERROR]: no argument or bad argument supplied; defaulting to \'required\'")

try:
    input_reciprocal_min = float(sys.argv[2])
    call.reciprocal_min = input_reciprocal_min
    print("Minimum reciprocal overlap is set to " + str(input_reciprocal_min))
except:
    print("[ERROR]: no argument or bad argument supplied; useing default value of 0.5")


print("CONSTRUCTING UNIONS")

#   iterate through all rows, for each row, construct a call instance
#   Check if this call instance intersects with any of the existing unions
#   If yes, add this call instance to the union
#   If no, construct a new empty union, add this call to the empty union, and add the new
#   union to the list of union
row_i = 0
while row_i < df.shape[0]:
    #   Construct the call instance
    call_i = call(sample_name = df['sample_name'].iloc[row_i],
                  chromosome = df['chromosome'].iloc[row_i],
                  start = df['start'].iloc[row_i],
                  stop = df['stop'].iloc[row_i],
                  state = df['state'].iloc[row_i],
                  caller = df['caller'].iloc[row_i],)

    #   If the union list is empty, construct an empty union, add the call instance
    #   and add the union to the union list
    if len(unions) == 0:
        union_j = union()
        union_j.add_call(call_i)
        unions.append(union_j)
    #   else, add this call to any union that intersects with this call
    else:
        #   Keep track of number of existing union that intersects with the new call
        n_intersection = 0
        for union_j in unions:
            if union_j.intersects_call(call_i):
                union_j.add_call(call_i)
                n_intersection += 1
        #   If no union intersects with the new call, make a new union, add the call
        #   and add the union
        if n_intersection == 0:
            union_j = union()
            union_j.add_call(call_i)
            unions.append(union_j)

    #   for debugging
    # print(row_i)

    row_i += 1

cons_unions = unions

# print("Remove singleton union")
# cons_unions = []
# for union_j in unions:
#     if union_j.count_calls() > 1:
#         cons_unions.append(union_j)

# print("There are " + str(len(cons_unions)) + " non-singleton unions")

print("MERGING UNIONS")

#   Define a method that checks if any 2 unions in the union list intersects
def contains_intersected_unions(union_list):
    #   iterate through every pair of union, return True if they intersect
    i = 0
    while i < len(union_list):
        j = i+1
        while j < len(union_list):
            union_i = union_list[i]
            union_j = union_list[j]

            if union_i.intersects_union(union_j):
                return True

            j += 1
        i += 1
    return False

#   Consolidate the unions in case some of them are actually the same union

while contains_intersected_unions(cons_unions):
    # print(len(cons_unions))
    #   Manage a list of unions that is the consolidated version of cons_unions
    new_cons_unions = []
    #   iterate through all pairs of unions
    i = 0
    while i < len(cons_unions):
        j = i+1
        while j < len(cons_unions):
            #   Get the pair
            union_i = cons_unions[i]
            union_j = cons_unions[j]

            #   If they intersect, add their merged union to new_cons_union
            if union_i.intersects_union(union_j):
                merged_union = union_i.merges(union_j)
                new_cons_unions.append(merged_union)
                #   remove the two unions used to form the merge
                cons_unions.remove(union_i)
                cons_unions.remove(union_j)
                # print("Merged a union")
                #   Add the rest of cons_unions to new_cons_unions and update
                new_cons_unions = new_cons_unions + cons_unions
                cons_unions = new_cons_unions
                #   break out of the loops
                break
                break
            j += 1
        i += 1

print("Checking consistency of union results")
union_unique_calls = sum([union_j.count_calls() for union_j in cons_unions])
is_consistent = union_unique_calls == df.shape[0]
if is_consistent:
    print("union results are consistent")
else:
    print("unions recorded " + str(union_unique_calls) + " unique calls while there are " + str(df.shape[0]) + " unique calls")

n_u1 = len([union_j for union_j in cons_unions if union_j.count_calls() == 1])
n_u2 = len([union_j for union_j in cons_unions if union_j.count_calls() == 2])
n_u3 = len([union_j for union_j in cons_unions if union_j.count_calls() == 3])
print("There are " + str(n_u1) + " unions with 1 call")
print("There are " + str(n_u2) + " unions with 2 call")
print("There are " + str(n_u3) + " unions with 3 call")
