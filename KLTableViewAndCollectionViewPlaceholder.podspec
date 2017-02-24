Pod::Spec.new do |s|
  s.name                = "KLTableViewAndCollectionViewPlaceholder"
  s.version             = "0.0.1"
  s.summary             = "A line of code implements the UITableView and UICollectionView placeholders."
  s.description         = "受 CYLTableViewPlaceHolder 启发，将更新数据的方法尽可能的封装(不只是 reload)，使得不用修改现有代码，及可非常容易的实现 UITableView 和 UICollectionView 的“无数据”提示，零成本。"
  s.homepage            = "https://github.com/klaus01/KLTableViewAndCollectionViewPlaceholder"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { "柯磊" => "kelei0017@gmail.com" }
  s.platform            = :ios, "6.0"
  s.source              = { :git => "https://github.com/klaus01/KLTableViewAndCollectionViewPlaceholder.git", :tag => "#{s.version}" }
  s.source_files        = "KLTableViewAndCollectionViewPlaceholder/*.{h,m}"
  s.public_header_files = "KLTableViewAndCollectionViewPlaceholder/KLTableViewAndCollectionViewPlaceholder.h"
  s.requires_arc        = true
end