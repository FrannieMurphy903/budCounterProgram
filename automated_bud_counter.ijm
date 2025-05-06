run("Clear Results"); // clear the results table of any previous measurements

// The next line prevents ImageJ from showing the processing steps during 
// processing of a large number of images, speeding up the macro
setBatchMode(true); 

path = getDirectory("image");
Dialog.create("Please enter your variables"); 
Dialog.addDirectory("Path to your image directory", path); 
Dialog.show();

path = Dialog.getString(); 

fileNames = getFileList(path);
fileNames = Array.sort(fileNames);

print("Image:,Budded cell count:,Unbudded cell count:,"); 

for (i = 0; i < fileNames.length; i++) {
    processImage(fileNames[i]);
}

setBatchMode(false); // Now disable BatchMode since we are finished
//updateResults(); 

// Show a dialog to allow user to save the results file
//outputFile = File.openDialog("Save results file");
// Save the results data
//saveAs("results",outputFile);

function processImage(imageFile) {
	
	prevNumResults = nResults; 
	
	open(path + "/" + imageFile);
	
	filename = getTitle(); 
	
	//run processing modules on the image

	run("Set Scale...", "distance=2048 known=133.12 unit=µm");

	setOption("ScaleConversions", true);
	run("8-bit");
	setAutoThreshold("Default dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Convert to Mask"); 
	for (i = 0; i < 4; i++) {
		run("Dilate"); 
	}
	run("Fill Holes"); 
	for (i = 0; i < 4; i++) {
		run("Erode"); 
	} 
	//measure the cells
	run("Set Scale...", "distance=2048 known=133.12 unit=um");
	run("Analyze Particles...", "size=4-51 circularity=0.4-1.00 exclude clear overlay");
	
	//Figure out how many cells were counted
	
	
	//Start by saving results as a csv
	saveAs("Results", path + "/results.csv");

	//Open csv as string
	x = File.openAsString(path + "/results.csv");
	
	//Separate file into rows
	rows = split(x,"\n");
	
	rowNumber = rows.length-1; 
	
	//sort cells into budded and unbudded
	
	budded = 0; 
	unbudded = 0; 
	
	for(i = 0; i < rowNumber; i++){
    	circularity = getResult("Circ.", i);
    	perimeter = getResult("Perim.", i); 
    	
    	if (circularity > 0.781) {
    		unbudded = unbudded + 1; 
    	}
    	
    	else {
    		ratio = perimeter/circularity; 
    		if (ratio < 14.9386) {
    			unbudded = unbudded + 1; 
    		}
    		else {
    			budded = budded + 1; 
    		}
    	}
	}
	
	print(filename + "," + budded + "," + unbudded); 
	
	results_delete = File.delete(path + "/results.csv");
	
    close("*");  // Closes all images
}
