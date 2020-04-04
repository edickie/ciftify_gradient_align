## checking if the dscalar outputs are formatted properly

In the output directory - run the following line.
If all outputs say " Type: CIFTI - Dense Scalar" - then the cifti files are good!
If all outputs say "Type: Connectivity Unknown (Could be Unsupported CIFTI File)" - then the cifti files need to be transposed.

```sh
cd ${output_directory}
for dscalar in */*/*gradients.dscalar.nii; do
  myline=$(wb_command -file-information ${dscalar} | grep Type: | head -1);
  echo ${dscalar} ${myline};
done
```
