import numpy as np
from common_interface_wrapper import FCMJoint
import matplotlib.pyplot as plt
import sys
np.random.seed(0)

device = 'cpu'
domType = 'TP'
nP = 1 
has_torque = False 
viscosity = 1 / 4 / np.sqrt(np.pi)
nTrials = 5
Ls = np.linspace(60,200,5)
solver = FCMJoint(device)
xP = np.zeros(3 * nP, dtype = np.double)
mobx = np.zeros((Ls.size,nTrials), dtype = np.double)
for iL in range(0,Ls.size):
  #Simulation domain limits
  xmin = 0.0; xmax = Ls[iL]
  ymin = 0.0; ymax = Ls[iL]
  zmin = 0.0; zmax = Ls[iL]
  solver.Initialize(numberParticles=nP, hydrodynamicRadius=1.0, kernType=0,
                    domType=domType, has_torque=has_torque,
                    xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, zmin=zmin, zmax=zmax,
                    viscosity=viscosity, optInd=0, ref=False, useRegKernel=False)
  for iTrial in range(0,nTrials):
    xP[0] = np.random.uniform(xmin, xmax-solver.hx)
    xP[1] = np.random.uniform(ymin, ymax-solver.hx)
    xP[2] = np.random.uniform(zmin, zmax-solver.hx)
    # pass the positions to the problem
    solver.SetPositions(xP)
    forces = np.array([1.0,0.0,0.0])
    # solve the mobility problem
    V, _ = solver.Mdot(forces)
    print(V)
    mobx[iL,iTrial] = V[0]
  print('\n')

# clear memory
solver.Clean()
fig,ax = plt.subplots(1,1)
ax.plot(1/Ls,mobx * (6 * np.pi * viscosity), 'rs', fillstyle='none')
plt.show()
