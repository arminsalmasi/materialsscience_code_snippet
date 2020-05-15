//____________________________________________
//________________________________________Main
//____________________________________________

//if results window is open then close//
if (isOpen("Results")) {
	selectWindow("Results");
	run("Clear Results");
}
//close all open images//
run("Close All");

//declerations//
folder_name="foldername";
input_path = "C:\\...\\"+folder_name+"\\";
subfolders=newArray("A","B","C",...);
output_path = "C:\\...\\"+folder_name+"\\processed\\";
file_type=".tif";
treshhold_1=0;
treshhold_2=160;
number_of_y_slices=10;
number_of_x_slices=5;
cut_scalebar=150; //cut the scalebar//


//get file names from folder//

requires("1.45s");
setOption("ExpandableArrays", true);

//creat output_path folder//
File.makeDirectory(output_path);
Array.print(subfolders);
//loop over subfolders//
for (subfolder = 0; subfolder <= subfolders.length-1; subfolder++) {
	print(subfolder,subfolders[subfolder]);
	file_list = getFileList(input_path+subfolders[subfolder]);
	File.makeDirectory(output_path+subfolders[subfolder]);
	
	//creat input and output path string//
	input=input_path+subfolders[subfolder];
	output=output_path+subfolders[subfolder];
	
	//filter image file with the given type//
	images=newArray(0);
	for (file = 0; file < file_list.length; file++) 
		if (endsWith(file_list[file], file_type)) {
			images=append(images,file_list[file]);
		}
	
	//loop over images in the subfolder 
	Array.print(images);
	for (image = 0; image < images.length; image++) 
		loop_over_images(input,output,treshhold_1,treshhold_2,images[image],number_of_y_slices,number_of_x_slices,cut_scalebar,file_type);
	if (isOpen("Results")) {
		selectWindow("Results");
		saveAs("Results",output+"\\results.csv");
		run("Clear Results");
	}
}	

//____________________________________________
//___________________________________Functions
//____________________________________________

//_______________________________________
//action commands
//record a macro the get needed cammands
//______________________________________
function action(x,y,dx,dy,counter,path,type,orig,imagename,slicenumber) {
	selectImage(original);
	makeRectangle(x,y,dx,dy);
	run("Duplicate...", " ");
	saveAs(path+'\\'+substring(imagename,0,lengthOf(imagename)-4)+"-"+(slicenumber+1)+"-org"+type);
	counter=counter+1;
	run("Smooth");
	run('Invert');
	// // //run("Enhance Contrast...", "saturated=0.5 normalize equalize");
	setAutoThreshold("Default");
	run("Measure");
	//setThreshold(treshhold_1, treshhold_2);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	// // //id1= getImageID();
	setResult("Label",slicenumber,substring(imagename,0,lengthOf(imagename)-4)+"-"+(slicenumber+1));
	print(substring(imagename,0,lengthOf(imagename)-4)+"-"+(slicenumber+1));
    updateResults();
	saveAs(path+'\\'+substring(imagename,0,lengthOf(imagename)-4)+"-"+(slicenumber+1)+"-pr"+type);
}


//____________________________________________
//loop over images in the path and save results
//_____________________________________________
function loop_over_images(path_in,path_out,treshhold_1,treshhold_2,file_name,number_of_h_slices,number_of_w_slices,cut_scale,ftype) {
	//open the image file//
	open(path_in+file_name);
	//make output subfolder//
	File.makeDirectory(path_out+substring(file_name,0,lengthOf(file_name)-4));
	//creat output image name//
	image_out_path = path_out+substring(file_name,0,lengthOf(file_name)-4);
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
	i=0;
	//select original image//
	selectImage(original);
	for (w_slice = 0;w_slice< number_of_w_slices;w_slice++) {
		//loop over h slices//
		for (h_slice = 0;h_slice< number_of_h_slices;h_slice++) {
			//loop over h slices//
			action(w,h,slice_width,slice_height,k,image_out_path,ftype,original,file_name,i);
			i=i+1;
			k=k+2;
			h=h+slice_height;
		}
		h=cut_scale;
		w=w+slice_width;
	}
	run('Close All');
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

