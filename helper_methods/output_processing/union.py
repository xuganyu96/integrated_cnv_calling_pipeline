#   the union class
from call import call

class union:

    #   a union is a collection of calls satisfying the following condition:
    #   for any 2 calls A_i and A_j, we can find a series of "intermediate" calls
    #   B_1, B_2, ..., B_n such that
    #   A_i and B_1 intersect, B_1 and B_2 intersect, ..., B_n and A_j intersect
    #
    #   Such "interconnectedness" is enforced by making sure that a call is
    #   added if and only if the list of calls is empty or there exists a call in
    #   the list that intersect with the new call

    def __init__(self):
        self.calls = []

    def contains(self, query_call):
        #   If the union is empty, return False
        if len(self.calls) == 0:
            return False
        #   return True iff the query call is in the list of existing calls
        for existing_call in self.calls:
            #   If there exists an existing call that has the same attributes
            #   as the query call, then they are the same call
            same_sample = existing_call.sample_name == query_call.sample_name
            same_chrom = existing_call.chromosome == query_call.chromosome
            same_start = existing_call.start == query_call.start
            same_stop = existing_call.stop == query_call.stop
            same_caller = existing_call.caller == query_call.caller
            same_state = existing_call.state == query_call.state
            if same_sample and same_chrom and same_start and same_stop and same_caller and same_state:
                return True
        #   We have exhausted all existing calls but found no match
        return False

    def intersects_call(self, new_call):
        #   return True if the new_call call object intersects with at least
        #   1 of the existing calls, or if the the call list is empty
        #   Return false if the union contains this call
        if self.contains(new_call):
            return False
        if len(self.calls) == 0:
            return True
        else:
            for existing_call in self.calls:
                if existing_call.intersects(new_call):
                    return True
            #   The list of existing call is none empty and no calls intersect
            #   with the new call
            return False

    def add_call(self, new_call):
        #   Add the call to the list of calls, but if and only if
        #   the new call is not in the list already and is intersecting with the union
        #   as described on the top, or if the union is empty
        if len(self.calls) == 0:
            self.calls.append(new_call)
        elif (not self.contains(new_call)) and self.intersects_call(new_call):
            self.calls.append(new_call)

    def get_union_start(self):
        #   return the leftmost of the start
        #   if the list is empty, return -1
        if len(self.calls) == 0:
            return -1
        else:
            starts = [call.start for call in self.calls]
            return min(starts)

    def get_union_stop(self):
        #   return the rightmost of the stops
        #   return -1 if the list of empty
        if len(self.calls) == 0:
            return -1
        else:
            stops = [call.stop for call in self.calls]
            return max(stops)

    def get_sample_name(self):
        #   return the name of the sample
        #   since all calls are from the same sample as enforced by add_call()
        #   just pick one and return it
        if len(self.calls) == 0:
            return "no_calls"
        else:
            return(self.calls[0].sample_name)

    def get_chromosome(self):
        #   return the chromosome
        #   since all calls are from the same sample as enforced by add_call()
        #   just pick one and return it
        if len(self.calls) == 0:
            return "no_calls"
        else:
            return(self.calls[0].chromosome)

    def get_state(self):
        #   return CNV type
        #   since all calls are from the same sample as enforced by add_call()
        #   just pick one and return it
        if len(self.calls) == 0:
            return "no_calls"
        else:
            return(self.calls[0].state)

    def count_calls(self):
        #   return the number of calls in the union
        return(len(self.calls))

    def count_callers(self):
        #   return the number of unique callers calling on this union
        unique_callers = set([call.caller for call in self.calls])
        return(len(unique_callers))

    def intersects_union(self, union_2):
        #   return True if any of the existing call in union_1 intersects
        #   with any of the calls in union_2

        #   To prevent exception:
        #   if any of the two unions are empty, return false
        if len(self.calls) == 0 or len(union_2.calls) == 0:
            return False
        else:
            for call_1 in self.calls:
                for call_2 in union_2.calls:
                    if call_1.intersects(call_2):
                        return True
            #   We have exhausted all combinations
            return False

    def merges(self, union_2):
        #   ONLY USE WHEN conditioned under intersects()!
        #   this method has no way of handling exception

        #   Return a union instance that contains all calls from union_1 and
        #   union_2
        all_calls = self.calls + union_2.calls

        new_union = union()

        #   For each of the calls in all_calls, attempt to add all calls from all_calls
        #   This is to prevent instance in which a call cannot be added until some
        #   other call is added
        for pointer in all_calls:
            for call in all_calls:
                new_union.add_call(call)

        #   return
        return new_union