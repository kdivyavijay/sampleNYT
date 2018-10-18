//


#import "ViewController.h"
#import "SideMenuManager.h"
#import "NYTimesCommonUtils.h"
#import "NewsDetailViewController.h"
#import "QuartzCore/QuartzCore.h"

#define API_KEY @"ce3628e9065d4b8ba8860862b735d7f9"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITableView *newsTbleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *_btn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"drawer_menu"]
											    style:UIBarButtonItemStylePlain
											   target:self
											   action:nil];
	
	self.navigationItem.leftBarButtonItem =_btn;
	UIImage* customImg = [UIImage imageNamed:@"menu"];
	UIBarButtonItem *_customButton = [[UIBarButtonItem alloc] initWithImage:customImg style:UIBarButtonItemStylePlain target:nil action:nil];
	UIImage* customImg2 = [UIImage imageNamed:@"search"];
	UIBarButtonItem *_customButton2 = [[UIBarButtonItem alloc] initWithImage:customImg2 style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.rightBarButtonItems= [NSArray arrayWithObjects:_customButton,_customButton2,nil];
	[self getValueFromServer];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)getValueFromServer
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?api-key=ce3628e9065d4b8ba8860862b735d7f9"]];
	
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (!error) {
			
			if (!FinalArray)
			{
				FinalArray = [[NSMutableArray alloc]init];
			}
			else{
				[FinalArray removeAllObjects];
			}
			NSError *jsonError = nil;
			NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
			if ([dictionary objectForKey:@"results"]) {
				[FinalArray addObjectsFromArray:[dictionary objectForKey:@"results"]];
			}
		}
		else{
			NSLog(@"Error: %@", [error localizedDescription]);
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"%@",[error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[_newsTbleView reloadData];
		});
		
	}];
	[task resume];
	
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchBtn:(id)sender
{
	
}
- (IBAction)leftMenuClicked:(id)sender {
    
    [[SideMenuManager sharedManager] showMenu:YES];
}

- (IBAction)rightMenuClicked:(id)sender {
    
    [[SideMenuManager sharedManager] showMenu:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 120;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *feedItem = [FinalArray objectAtIndex:indexPath.row];
	if ([NYTimesCommonUtils objectIsValid:feedItem]) {
		NewsDetailViewController * detail = [[NewsDetailViewController alloc] init];
		detail.feedDictionary = feedItem;
		[self presentViewController:detail animated:NO completion:nil];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return FinalArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"MostViewedFeedTableViewCell";
	customTableViewCell *cell = (customTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	NSDictionary *feedItem = [FinalArray objectAtIndex:indexPath.row];
	
	if (cell == nil){
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	cell.hidden= NO;
	cell.titleLbl.text = [feedItem objectForKey:@"title"];
	cell.titleLbl.numberOfLines =2;
	cell.titleLbl.textColor = [UIColor blackColor];
	[cell.contentView addSubview:cell.titleLbl];
	cell.contentView.hidden = NO;
	cell.detailLbl.text = [feedItem objectForKey:@"byline"];
	cell.detailLbl.numberOfLines =2;
	if([cell.detailLbl.text length]>60){
		NSRange stringRange = {0, MIN([cell.detailLbl.text length], 60)};
		
		// adjust the range to include dependent chars
		stringRange = [cell.detailLbl.text rangeOfComposedCharacterSequencesForRange:stringRange];
		
		// Now you can create the short string
		NSString *shortString = [cell.detailLbl.text substringWithRange:stringRange];
		
		cell.detailLbl.text = shortString;
	}
	[cell.detailLbl sizeToFit];

	cell.detailLbl.textColor = [UIColor lightGrayColor];
	cell.timLbl.text = [feedItem objectForKey:@"published_date"];
	cell.timLbl.textColor = [UIColor lightGrayColor];

	NSArray *mediaArray = [feedItem objectForKey:@"media"];
	NSDictionary *mediaInfoDictionary = [mediaArray objectAtIndex:0];
	NSArray *mediaMetaDataArray = [mediaInfoDictionary objectForKey:@"media-metadata"];
	cell.imgView.layer.cornerRadius = 23;
	cell.imgView.layer.masksToBounds = YES;
	[cell.contentView addSubview:cell.imgView];
	if ([NYTimesCommonUtils objectIsValid:mediaMetaDataArray]) {
		
		NSDictionary *feedImageDictionary = [mediaMetaDataArray objectAtIndex:1];
		
		// Set up a NSURL for the image you want.
		NSURL *imageURL = [NSURL URLWithString:[feedImageDictionary objectForKey:@"url"]];
		
		// Check if the URL is valid
		if ( imageURL ) {
			// The URL is valid so we'll use it to load the image asynchronously.
			// remote image loads.
			cell.imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
		}
		else {
			// The imageURL is invalid, just show the placeholder image.
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.imgView.image = nil;
			});
		}
		cell.imageView.clipsToBounds = YES;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

@end
