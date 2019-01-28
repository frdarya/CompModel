# -*- coding: utf-8 -*-
"""
Created on Wed Aug 15 16:05:15 2018

@author: daryafrank
"""
# to clear previous variable from workspace type %reset in ipython console
import numpy as np
import pandas as pd

def createFoil(changeUnits,addID,target,add_idx):
    """ change units = number of foils to change,
        add ID = where to start couniting in add_idx (unused units)
    """
    rmv_idx = np.random.permutation(12)[0:changeUnits] #choose unit numbers
    idx_targ = np.where(target==1)[0] # find used units from target
    foil_idx = idx_targ[rmv_idx] # select X of the used units
    foil = np.copy(target) 
    foil[foil_idx] = 0 # flip the selected units in foil_idx
    np.random.shuffle(add_idx) # shuffle them
    add_1 = add_idx[addID:addID+changeUnits] # add X other units to replace them
    foil[add_1]=1 
    idx_f = np.where((foil==1))[0]
    # sanity checks
    assert np.size(np.where(foil==1)[0]) == 12, 'Foil doesnt have 12 units!'
    assert np.size(np.setdiff1d(idx_targ,idx_f)) == changeUnits,'Difference between targets and foil isnt right!'
    return foil
    
# create 4 objects  
All_Test = np.empty((40,54))
Train = np.empty((4,54))
i = 0
for object in range(0,4):
    target = np.zeros([48,1])
    one_idx = np.random.permutation(48)[0:12] # create target with 12 random units
    target[one_idx] = 1   
    add_idx = np.setdiff1d(np.arange(0,48),one_idx) #find unused units
    
    foil1 = createFoil(2,0,target,add_idx)
    foil2 = createFoil(4,2,target,add_idx)
    foil3 = createFoil(6,6,target,add_idx)
    foil4 = createFoil(8,12,target,add_idx)
    
    Man = np.hstack((target,foil1,foil2,foil3,foil4))
    Man = Man.transpose()
    Nat = np.hstack((target,foil1,foil2,foil3,foil4))
    Nat = Nat.transpose()
    
    if object % 2 == 0:
        cue = np.concatenate((np.zeros(3),np.array([0.9,0.9,0.9]))) # create the 1D array
        cue = np.tile(cue, [5,1]) # repmat 5 times
        ExpMan=np.hstack((Man,cue))
        unexCue = np.concatenate((np.array([0.9,0.9,0.9]),np.zeros(3)))
        unexCue = np.tile(unexCue, [5,1]) # repmat 5 times
        UnexMan = np.hstack((Man,unexCue))
        Obj = np.concatenate((ExpMan,UnexMan),axis=0)
    else:
        cue = np.concatenate((np.array([0.9,0.9,0.9]),np.zeros(3)))
        cue = np.tile(cue, [5,1]) 
        ExpNat = np.hstack((Nat,cue))
        unexCue = np.concatenate((np.zeros(3),np.array([0.9,0.9,0.9]))) 
        unexCue = np.tile(unexCue, [5,1]) # repmat 5 times
        UnexNat = np.hstack((Nat,unexCue))
        Obj = np.concatenate((ExpNat,UnexNat))
        
    All_Test[i:i+10,0:54] = Obj
    Train[object,0:54] = Obj[0]
    Obj = []
    i += 10


# duplicate for inputs and outpus
All_Test = np.tile(All_Test,[1,2])
Train = np.tile(Train,[1,2])

# create column headers
Inps = ['Input_%s' %s for s in list(range(0,54))] 
Outs = ['EC_out_%s' %s for s in list(range(0,54))]
cols = Inps + Outs

# create row names
idx = ['a_targ_e','a_f1_e','a_f2_e','a_f3_e','a_f4_e',
       'a_targ_u','a_f1_u','a_f2_u','a_f3_u','a_f4_u',
       'b_targ_e','b_f1_e','b_f2_e','b_f3_e','b_f4_e',
       'b_targ_u','b_f1_u','b_f2_u','b_f3_u','b_f4_u',
       'c_targ_e','c_f1_e','c_f2_e','c_f3_e','c_f4_e',
       'c_targ_u','c_f1_u','c_f2_u','c_f3_u','c_f4_u',
       'd_targ_e','d_f1_e','d_f2_e','d_f3_e','d_f4_e',
       'd_targ_u','d_f1_u','d_f2_u','d_f3_u','d_f4_u']
# convert to pandas and export to csv
dfTest = pd.DataFrame(All_Test, columns = cols, index = idx)
dfTest.to_csv("Test_Python1.csv")

dfTrain = pd.DataFrame(Train, columns = cols, index = ['a_targ','b_targ','c_targ','d_targ'])
dfTrain.to_csv("Train_Python1.csv")