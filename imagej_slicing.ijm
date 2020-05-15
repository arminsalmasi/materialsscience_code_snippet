//________________________________________Functions

//____________________________________________
//loop over images in the path and save results
//_____________________________________________

function loop_over_images(path_in,path_out,treshhold_1,treshhold_2,file_name,number_of_h_slices,number_of_w_slices,cut_scale,ftype) {
	//open the image file//
	open(path_in+file_name);
	//make output subfolder//
	File.makeDirectory(path_out+substring(file_name,0,lengthOf(file_name)-4));
	//creat output image name//
	image_out_name = path_out+substring(file_name,0,lengthOf(file_name)-4);
	//get original image id//
	original = getImageID();
	// cut out the scale # number of pixels # h direction//
	image_width = getWidth();
	image_height = getHeight();
	slice_width=(floor(image_width/number_of_w_slices));
	slice_height=(floor((image_height-cut_scale)/number_of_h_slices));
	k=1; //place holder counter//
	w=1; //first pixel in w direction//
	h=cut_scale;
	//loop over w slices//
	for (w_slice = 0;w_slice< number_of_w_slices;w_slice++) {
		//select original image//
		selectImage(original);
		//loop over h slices//
		for (h_slice = 0;h_slice< number_of_h_slices;h_slice++) {
			//loop over h slices//
			selectImage(original);
			action(w,h,slice_width,slice_height,k,image_out_name,ftype);
			k=k+2;
			h=h+slice_height;
		}
		h=cut_scale;
		w=w+slice_width;
	}
	selectWindow("Results");
	saveAs("Results",path_out+"\\results.csv");
	run('Close All');
}

//_______________________________________
//action commands
//record a macro the get needed cammands
//______________________________________

function action(x,y,dx,dy,slice_number,path,type) {
	makeRectangle(x,y,dx,dy);
	run("Duplicate...", " ");
	saveAs(path+'\\'+slice_number+type);
	print(slice_number);
	slice_number=slice_number+1;
	run("Smooth");
	run('Invert');
	// //run("Enhance Contrast...", "saturated=0.5 normalize equalize");
	setAutoThreshold("Default");
	//setThreshold(treshhold_1, treshhold_2);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Measure");
	id1= getImageID();
	saveAs(path+'\\'+slice_number+type);
	print(slice_number);
}

//_____________________________
//append one elemnt to an array
//_____________________________

function append(arr, value) {
    arr2 = newArray(arr.length+1);
    for (i=0; i<arr.length; i++)
		arr2[i] = arr[i];
    arr2[arr.length] = value;
    return arr2;
}

//____________________________________________
//________________________________________Main
//____________________________________________

//declerations//
folder_name="your folder name";
input_path = "C:\\....\\"+folder_name+"\\";
subfolders=newArray("subfolder1\\","subfolder2\\",....);
output_path = "C:\\....\"+folder_name+"\\imagej_sliced\\";
file_type=".tif";
treshhold_1=0;
treshhold_2=160;
number_of_y_slices=5;
number_of_x_slices=5;
cut_scalebar=150; //cut the scalebar on the top-you can change the code to cut from the bottom as well//

//ife results window is open then close//
if (isOpen("Results")) {
	selectWindow("Results");
	run("Clear Results");
}

//get file names from folder//
images=newArray(0);
requires("1.45s");
setOption("ExpandableArrays", true);

//creat output_path folder//
File.makeDirectory(output_path);

//loop over subfolders//
for (subfolder = 0; subfolder <= subfolders.length-1; subfolder++) {
	file_list = getFileList(input_path+subfolders[subfolder]);
	File.makeDirectory(output_path+subfolders[subfolder]);
	
	//creat input and output path string//
	input=input_path+subfolders[subfolder];
	output=output_path+subfolders[subfolder];
	
	//filter image file with the given type//
	for (file = 0; file < file_list.length-1; file++) 
		if (endsWith(file_list[file], file_type)) {
			images=append(images,file_list[file]);
		}
	
	//loop over images in the subfolder 
	for (image = 0; image < images.length-1; image++) 
		loop_over_images(input,output,treshhold_1,treshhold_2,images[image],number_of_y_slices,number_of_x_slices,cut_scalebar,file_type);
		//close the results window//
		selectWindow("Results");
		run("Clear Results");
}	




	

