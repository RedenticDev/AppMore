@interface UIView (Private)
- (void)moreFrom:(id)arg1;
@end

%hook UIView

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([NSStringFromClass([((UIView *)self) class]) isEqualToString:@"AppStore.ExpandableTextView"]) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)layoutSubviews {
    %orig;
    if ([NSStringFromClass([((UIView *)self) class]) isEqualToString:@"AppStore.ExpandableTextView"]) {
        if (MSHookIvar<BOOL>(self, "isCollapsed")) {
            [self moreFrom:self];
            if ([self.superview isKindOfClass:%c(UITableViewCellContentView)]) {
                [self.superview setNeedsDisplay];
            }
        }
    }
}

%end
