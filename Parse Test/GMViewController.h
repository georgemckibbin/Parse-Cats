//
//  GMViewController.h
//  Parse Test
//
//  Created by George McKibbin on 13/02/2014.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

// Parse class names and keys
#define CAT_CLASS_NAME @"Cat"
#define CAT_NAME_KEY @"catName"
#define CAT_IMAGE_KEY @"catImage"

@interface GMViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

// IB Outlets
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Action for the save button
- (IBAction)saveClicked:(id)sender;

@end
