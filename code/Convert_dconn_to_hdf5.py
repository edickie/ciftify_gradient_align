import h5py
import nibabel as nib

def convert_to_hdf5(dconn_file):
    dconn = nib.load(dconn_file)
    
    # convert the file endings
    hdf5_file = dconn_file.replace("nii", "hdf5")
    
    with h5py.File(hdf5_file) as f:
        dset = f.create_dataset("dconn", data=dconn.get_data())

        
convert_to_hdf5("data/dconn.nii/HCP_S1200_812_rfMRI_MSMAll_groupPCA_d4500ROW_zcorr_recon2.dconn.nii")