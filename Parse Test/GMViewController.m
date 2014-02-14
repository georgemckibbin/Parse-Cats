//
//  GMViewController.m
//  Parse Test
//
//  Created by George McKibbin on 13/02/2014.
//
//

#import "GMViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CAT_1_IMAGE_FILE_NAME @"cat.jpg"
#define CAT_2_IMAGE_FILE_NAME @"cat2.jpeg"
#define CAT_3_IMAGE_FILE_NAME @"cat3.jpg"

@interface GMViewController ()

// This is where we store all the cats that we fetch from parse.
@property (strong, nonatomic) NSArray *cats;

// Just some private properties to keep track of the current cat image.
@property (assign, nonatomic) int currentCatNumber;
@property (strong, nonatomic) UIImage *catImage;

// Just the refresh control that we attached to the UICollectionView in viewDidLoad
@property (weak, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation GMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Make the image view round. This is iOS7 after all!
	[self.imageView.layer setCornerRadius:75.0];
	[self.imageView setClipsToBounds:YES];
	
	// Add Tap Gesture to Image View
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
	[self.imageView addGestureRecognizer:tapGesture];
	
	//Add refresh control to UICollectionView
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	refreshControl.tintColor = [UIColor whiteColor];
	[refreshControl addTarget:self action:@selector(refreshCats) forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:refreshControl];
	self.refreshControl = refreshControl;
	self.collectionView.alwaysBounceVertical = YES;
	
	// Initialise cats, important
	self.currentCatNumber = 0;
	self.catImage = [UIImage imageNamed:CAT_1_IMAGE_FILE_NAME];
}


-(void)viewDidAppear:(BOOL)animated
{
	// If there's no used logged in show the log in controller
	if (![PFUser currentUser])
	{
		// Create Log In view controller
		PFLogInViewController *loginVC = [PFLogInViewController new];
		loginVC.delegate = self;
		
		// Create the Sign in view controller
		PFSignUpViewController *signUpVC = [PFSignUpViewController new];
		signUpVC.delegate = self;
		
		// Set the Sign up VC to the Log in VC
		loginVC.signUpController = signUpVC;
		
		// Show the controller
		[self presentViewController:loginVC
						   animated:YES
						 completion:nil];
	}
}


// Switch between the cat images
- (void)changeImage
{
	// Based on the currently set cat, switch to the next cat image.
	switch (self.currentCatNumber)
	{
		case 0:
			self.currentCatNumber = 1;
			self.catImage = [UIImage imageNamed:CAT_2_IMAGE_FILE_NAME];
			break;
		case 1:
			self.currentCatNumber = 2;
			self.catImage = [UIImage imageNamed:CAT_3_IMAGE_FILE_NAME];
			break;
		default:
			self.currentCatNumber = 0;
			self.catImage = [UIImage imageNamed:CAT_1_IMAGE_FILE_NAME];
			break;
	}
	
	// Set the image view's image to the new cat image
	self.imageView.image = self.catImage;
}

- (void)refreshCats
{
	// Simple query to get all the cat objects, every single one.
	PFQuery *catQuery = [PFQuery queryWithClassName:CAT_CLASS_NAME];
	
	// Find all the CATS!
	[catQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		// Using the returned objects set the private property that stores all the cats.
		self.cats = objects;
		
		// Stop that refresh control from refreshing
		[self.refreshControl endRefreshing];
		
		// Reload the collection view and show these cats we just found.
		[self.collectionView reloadData];
	}];
	
}

- (IBAction)saveClicked:(id)sender
{
	// Declare a new Parse object that is of 'cat' type.
	PFObject *newCat = [PFObject objectWithClassName:CAT_CLASS_NAME];
	
	// Just like a dictionary, set the name of the cat on the newcat parse object.
	newCat[CAT_NAME_KEY] = self.textField.text;
	
	// When saving a file to parse you first have to create a PFFile object and save it seperately
	PFFile *catImage = [PFFile fileWithName:@"cat.jpg" data:UIImageJPEGRepresentation(self.catImage, 0.6) ];
	[catImage saveInBackground];
	
	// Then set that PFFile objects to your PFObject
	newCat[CAT_IMAGE_KEY] = catImage;
	
	// Then save the original PFObject, this block won't return until the file has also save. Parse Magic!
	[newCat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (succeeded)
		{
			[[[UIAlertView alloc] initWithTitle:@"Hooray"
									   message:@"Cat was saved to Parse"
									  delegate:nil
							 cancelButtonTitle:@"Good that"
							 otherButtonTitles:nil] show];
		}
	}];
}

#pragma mark - Text Field methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// Dismiss Keyboard
	[self.textField resignFirstResponder];
	return YES;
}

#pragma mark - Collection View methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	// Just the one section
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	// Once we've set the property for the cats with the results of the PFQuery, this will return how many cats I've created.
	return [self.cats count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	// Basic set up of the UICollectionViewCell
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"catCell" forIndexPath:indexPath];
	PFImageView *imageView = (PFImageView *)[cell viewWithTag:1];
	imageView.clipsToBounds = YES;
	imageView.layer.cornerRadius = imageView.frame.size.width / 2;
	
	// Grab the Cat Parse object that this row relates to
	PFObject *cat = [self.cats objectAtIndex:indexPath.row];
	
	// Since we've used PFImageView we just set the file and tell it to load in the background
	imageView.file = cat[CAT_IMAGE_KEY];
	[imageView loadInBackground];
	
	// Set the label to the cat's name.
	UILabel *label = (UILabel *)[cell viewWithTag:2];
	label.text = cat[CAT_NAME_KEY];
	
	// Return this lovely cell full of the data we previously grabbed from Parse. Easy!
	return cell;
}

// The only delegate methods for the Log in and Sign up views that you need to implement are the ones that tell this views to go away once they're done.
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
