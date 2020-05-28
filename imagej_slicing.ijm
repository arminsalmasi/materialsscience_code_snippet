//_______________________________main
root="C:\\...";
headfolder="\\..."
root=root+headfolder;
folders=newArray("a","b",...);
outputfolder=root+"\\"+"output";


file_type=".tif";
th_1=0;
th_2=50;
n_y_slices=5;
n_x_slices=5;
cut_scalebar=150; 
for (folder = 0; folder < folders.length; folder++) {
	input=root+"\\"+folders[folder]+"\\";
	File.makeDirectory(outputfolder);
	output=outputfolder+"\\"+folders[folder]+"\\";
	loop_subfolder(input,output,th_1,th_2,n_y_slices,n_x_slices,cut_scalebar,file_type);
}
//________________________________________action commands
function action(th_1,th_2) {
	run("Smooth");
	run('Invert');
	setAutoThreshold("Default");
	run("Measure");
	setOption("BlackBackground", false);
	run("Convert to Mask");
}

//________________________________________loop_subfolder
function loop_subfolder(input,output,th_1,th_2,n_y_slices,n_x_slices,cut_scalebar,file_type) {
	if (isOpen("Results")) {
		selectWindow("Results");
		run("Clear Results");
	}
	requires("1.45s");
	setOption("ExpandableArrays", true);
	File.makeDirectory(output);
	file_list = getFileList(input);
	images=newArray(0);
	for (file = 0; file < file_list.length; file++) 
		if (endsWith(file_list[file], file_type)) {
			images=append(images,file_list[file]);
		}
	for (image = 0; image < images.length; image++) 
		slice_image(input,output,th_1,th_2,images[image],n_y_slices,n_x_slices,cut_scalebar,file_type);
	if (isOpen("Results"))  {
		selectWindow("Results");
		saveAs("Results",output+"res.csv");
		run("Clear Results");
	}
}

//________________________________________loop images
function slice_image(pin,pout,th_1,th_2,img_name,n_h_slices,n_w_slices,cut_scale,ftype) {
		//print(img_name);
		open(pin+img_name);
		File.makeDirectory(pout+substring(img_name,0,lengthOf(img_name)-4));
		image_outpath = pout+substring(img_name,0,lengthOf(img_name)-4);
		orgID = getImageID();
		image_w = getWidth();
		image_h = getHeight();
		slice_w=(floor(image_w/n_w_slices));
		slice_h=(floor((image_h-cut_scale)/n_h_slices));
		w=1;
		h=cut_scale;
		n_slice=0;  
		for (w_slice = 0;w_slice< n_w_slices;w_slice++) {
			for (h_slice = 0;h_slice< n_h_slices;h_slice++) {
					selectImage(orgID);
					makeRectangle(w,h,slice_w,slice_h);
					run("Duplicate...", "title="+toString(substring(img_name,0,lengthOf(img_name)-4)) + "-" + toString(n_slice+1));
					print(getTitle);
					saveAs(image_outpath+'\\'+getTitle+"-org");
					action(th_1,th_2);
					saveAs(image_outpath+'\\'+getTitle+"-pr");
					//setResult("Label", n_slice, toString(substring(img_name,0,lengthOf(img_name)-4)) + "-" + toString(n_slice+1));
					//print(toString(substring(img_name,0,lengthOf(img_name)-4)) + "-" + toString(n_slice+1));
					//updateResults();
				n_slice=n_slice+1;
				h=h+slice_h;
			}
			h=cut_scale;
			w=w+slice_w;
		}
		run('Close All');
}	

//________________________________________append one elemnt to an array
function append(arr, value) {
    arr2 = newArray(arr.length+1);
    for (i=0; i<arr.length; i++)
		arr2[i] = arr[i];
    arr2[arr.length] = value;
    return arr2;
	}
