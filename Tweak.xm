@interface UICollectionView (AppMore)
@property (nonatomic, retain) NSMutableArray *expandedViewsPaths; // contains cells where text is expanded
@property (nonatomic, retain) NSMutableArray *otherViewsPaths; // other non-update cells already met
- (id)_viewControllerForAncestor; // contains the name of the view controller of a given view
@end

@interface UICollectionViewCell (AppMore)
@property (nonatomic, retain) id accessibilityExpandableTextView; // update cell description view
- (void)moreFrom:(id)arg1; // method that expand text, called when pressing 'more' button
@end

%hook UICollectionView // objc closest superview of the update page (cause swift cannot be hooked)

// 'synthesizing' properties
%property (nonatomic, retain) NSMutableArray *expandedViewsPaths;
%property (nonatomic, retain) NSMutableArray *otherViewsPaths;

- (void)layoutSubviews { // called while scrolling
    %orig;
    if ([NSStringFromClass([self._viewControllerForAncestor class]) isEqualToString:@"AppStore.AccountViewController"]) { // if we are in the good AppStore page (swift version)
        if (!self.expandedViewsPaths) self.expandedViewsPaths = [[NSMutableArray alloc] init];
        if (!self.otherViewsPaths) self.otherViewsPaths = [[NSMutableArray alloc] init];
        for (NSIndexPath *path in self.indexPathsForVisibleItems) { // loop through visible items
            id cell = [self cellForItemAtIndexPath:path]; // define the cell
            if ([NSStringFromClass([cell class]) isEqualToString:@"AppStore.UpdatesLockupCollectionViewCell"]) { // if the cell is an update cell (swift version)
                if (![self.expandedViewsPaths containsObject:path]) { // if view not already browsed
                    NSLog(@"[AppMore] New valid cell detected: %@", cell);
                    id textView = ((UICollectionViewCell *)cell).accessibilityExpandableTextView; // define description
                    if (MSHookIvar<BOOL>(textView, "isCollapsed")) { // if description is not already expanded
                        NSLog(@"[AppMore] Expanding text for cell: %@", cell);
                        [textView moreFrom:textView]; // expand description
                        [self reloadItemsAtIndexPaths:@[path]]; // refresh view...
                        [self.expandedViewsPaths addObject:path]; // ... and add it in browsed array
                        NSLog(@"[AppMore] Expanded cells count is now %lu: %@", self.expandedViewsPaths.count, [self.expandedViewsPaths componentsJoinedByString:@" • "]);
                    }
                }
            } else if (![self.otherViewsPaths containsObject:path]) { // if cell is not an update cell and if it has not been browsed
                [self.otherViewsPaths addObject:path]; // add to wrong browsed views array
                NSLog(@"[AppMore] Invalid cell detected, new count is %lu: %@", self.otherViewsPaths.count, [self.otherViewsPaths componentsJoinedByString:@" • "]);
            }
        }
    }
}

%end
