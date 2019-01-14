#   the call class

class call:

    #   If require_reciprocal is true, then the intersection has to be reciporcal_min
    #   of BOTH calls
    #   if not, just one is good enough
    require_reciprocal = True
    reciprocal_min = 0.5

    #   A "call" correspond to a single CNV call made by a single caller on
    #   a single continuous region of a sample's certain chromosome
    #
    #   A single "call" instance should contain all information contained
    #   in a single row in the tcnv files except for q_some, which I have no use for yet

    def __init__(self, sample_name, chromosome, start, stop, state, caller):
        self.sample_name = sample_name
        self.chromosome = chromosome
        #   start and stop will be converted to integer for computation
        self.start = int(start)
        self.stop = int(stop)
        self.state = state
        self.caller = caller

    def intersects(self, call_2, reciprocal=reciprocal_min):
        #   return true if self and call_2 intersect reciprocally for at least
        #   certain percentage of the call

        #   If they are not from the same chromosome of the same sample
        #   Or if they are not the same type of CNV
        #   return false
        if self.sample_name != call_2.sample_name:
            return False
        elif self.chromosome != call_2.chromosome:
            return False
        elif self.state != call_2.state:
            return False

        #   Now that we have confirmed they are on the same person's same chromosome
        #   let's compute the length of intersection
        A_range = range(self.start, self.stop)
        B_range = range(call_2.start, call_2.stop)
        A_set = set(A_range)
        inter_length = len(set(A_set.intersection(B_range)))
        A_inter_percent = float(inter_length) / len(A_range)
        B_inter_percent = float(inter_length) / len(B_range)

        if self.require_reciprocal:
            return(A_inter_percent > reciprocal and B_inter_percent > reciprocal)
        else:
            return(A_inter_percent > reciprocal or B_inter_percent > reciprocal)
