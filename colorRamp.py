import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

#from colorspacious import cspace_converter

mat = np.random.random((10,10))
plt.imshow(mat, origin="lower", cmap=cm.get_cmap("Spectral"), interpolation='nearest')
plt.colorbar()





#plt.plot(y)
plt.axis('off')
#plt.gca().set_position([0, 0, 1, 1])
plt.savefig("C:/Users/chris/plots/test.svg")


plt.show()