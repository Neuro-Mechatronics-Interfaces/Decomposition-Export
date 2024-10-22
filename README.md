# Decomposition-Export #

## Steps ## 
1. Export from your binary (.poly5, .rhd, etc) to format compatible with an Intan reader.
* To use Max 128-ch CKC reader, file must contain the following variables:
  + `uni` - `nChannels` x `nTimesteps` filtered/referenced/cleaned data from all electrodes (`double`). 
  + `sample_rate` - Acquisition sample rate (scalar `double`).
  + `description` - Description of these data (MATLAB string variable).
  + `aux` - Either an empty array (`[]`) or some reference channel you want for visual purposes only. Should be a `double` row vector, if provided. 
  + `sync` - Some key reference signal from the experiment (analog or digital). Should be a `double` row vector.  
 
2. Save `.mat` files to `Google Share Drive` somewhere you can access. 

3. Login to DEMUSE machine using `AnyDesk` at `229 968 619`. Download your `.mat` files (preferably to somewhere indicating they belong to you/your project). 

4. Launch `matlab` from a command terminal. Navigate to `/home/nvidia2080ti/demuse/DEMUSE` (or something like that) in the MATLAB workspace. Enter `DEMUSE()` in the Command Window and hit enter.

5. Run your batch decomposition by selecting a folder containing the folder with all files you want for your decomposition. Note that if there are multiple folders at this level, it will add all of them to the batch run (you may or may not want that).  

6. Upload your batch decomposition results to `Google Share Drive`. 
  + These files will contain variable `IPTs` which are the weighted, whitened projections that are the individual motor unit "impulse" trains. These vectors are thresholded to get sample instants in corresponding elements of `MUPulses`, which are the actual firing instants. 
7. **Delete your files from DEMUSE computer when done please!**

8. Use `autoClean.m` to help clean-up decomposition (optional). 

9. Curate remaining touch-ups manually using DEMUSE on your local device.   