@interface UICollectionView (AppMore)
- (id)_viewControllerForAncestor; // contains the name of the view controller of a given view
@end

@interface UICollectionViewCell (AppMore)
@property (nonatomic, retain) id accessibilityExpandableTextView; // update cell description view
- (void)moreFrom:(id)arg1; // method that expand text, called when pressing 'more' button
@end

%hook UICollectionView // objc closest superview of the update page (cause swift cannot be hooked)

static NSMutableArray *expandedViewsPaths = [[NSMutableArray alloc] init]; // contains cells where text is expanded
static NSMutableArray *otherViewsPaths = [[NSMutableArray alloc] init]; // other non-update cells already met

- (void)layoutSubviews { // called while scrolling
    %orig;
    if ([NSStringFromClass([self._viewControllerForAncestor class]) isEqualToString:@"AppStore.AccountViewController"]) { // if we are in the good AppStore page (swift version)
        for (NSIndexPath *path in self.indexPathsForVisibleItems) { // loop through visible items
            id cell = [self cellForItemAtIndexPath:path]; // define the cell
            if ([NSStringFromClass([cell class]) isEqualToString:@"AppStore.UpdatesLockupCollectionViewCell"]) { // if the cell is an update cell (swift version)
                if (![expandedViewsPaths containsObject:path]) { // if view not already browsed
                    NSLog(@"[AppMore] New valid cell detected: %@", cell);
                    id textView = ((UICollectionViewCell *)cell).accessibilityExpandableTextView; // define description
                    if (MSHookIvar<BOOL>(textView, "isCollapsed")) { // if description is not already expanded
                        NSLog(@"[AppMore] Expanding text for cell: %@", cell);
                        [textView moreFrom:textView]; // expand description
                        [self reloadItemsAtIndexPaths:@[path]]; // refresh view...
                        [expandedViewsPaths addObject:path]; // ... and add it in browsed array
                        NSLog(@"[AppMore] Expanded cells count is now %lu: %@", expandedViewsPaths.count, [expandedViewsPaths componentsJoinedByString:@" • "]);
                    }
                }
            } else if (![otherViewsPaths containsObject:path]) { // if cell is not an update cell and if it has not been browsed
                [otherViewsPaths addObject:path]; // add to wrong browsed views array
                NSLog(@"[AppMore] Invalid cell detected, new count is %lu: %@", otherViewsPaths.count, [otherViewsPaths componentsJoinedByString:@" • "]);
            }
        }
    }
}

- (void)dealloc { // empty arrays when view dismissed
    [expandedViewsPaths removeAllObjects];
    [otherViewsPaths removeAllObjects];
    NSLog(@"[AppMore] Views caches cleared");
    %orig;
}

%end
