import peer
import scipy as SP
import pickle
import numpy
from optparse import OptionParser

# Set up the option parser
parser = OptionParser()

parser.add_option("-i", "--input", dest="input_file",
                  help="path to the input file", metavar="FILE")
parser.add_option("-o", "--output", dest="output_folder",
                  help="path to the output folder", metavar="FOLDER")

(options, args) = parser.parse_args()

# Check if the options are provided
if not options.input_file or not options.output_folder:
    parser.error("Both input file and output folder are required.")

expr = SP.loadtxt(options.input_file, delimiter=',')

model = peer.PEER()
model.setPhenoMean(expr)
expr.shape

# 25% of samples as hidden confounders
model.setNk(48)

# set max iterations
model.setNmax_iterations(100)

# set model tolerance
# model.setTolerance(0.5)
# model.setVarTolerance(0.05)

# run
model.update()

factors = model.getX()
pickle.dump(factors, open(options.output_folder + "/save.X", "wb"))
numpy.savetxt(options.output_folder + "/factors.txt", factors)

weights = model.getW()
pickle.dump(weights, open(options.output_folder + "/save.W", "wb"))
numpy.savetxt(options.output_folder + "/weights.txt", weights)

precision = model.getAlpha()
pickle.dump(precision, open(options.output_folder + "/save.Alpha", "wb"))
numpy.savetxt(options.output_folder + "/precision.txt", precision)

residuals = model.getResiduals()
pickle.dump(residuals, open(options.output_folder + "/save.residuals", "wb"))
numpy.savetxt(options.output_folder + "/residuals.txt", residuals)
