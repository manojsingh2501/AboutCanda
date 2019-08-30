//  Copyright © 2019 Cognizant. All rights reserved.

import UIKit
import Result
import AsyncDisplayKit
import ReactiveSwift
import SnapKit

private let refreshTimeInterval: TimeInterval = 1 * 60

class SectionViewController: UIViewController {
    private var refreshTimestamp = Date(timeIntervalSince1970: 0.0)
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let refreshControl = UIRefreshControl()
    
    private let layoutInspector = SectionCollectionViewLayoutInspector()
    private let sectionCollectionViewLayout = SectionCollectionViewLayout()
    private let collectionNode: ASCollectionNode
    private var lastViewSize: CGSize = .zero
    private var isFetchingContent = false
    private var exonyms: [Country.Exonym] = []
    private var sectionAttributes: [SectionAttributes] = []
    
    init() {
        collectionNode = ASCollectionNode(collectionViewLayout: sectionCollectionViewLayout)
        super.init(nibName: nil, bundle: nil)
        
        sectionCollectionViewLayout.delegate = self
        collectionNode.layoutInspector = self.layoutInspector
        collectionNode.dataSource = self
        collectionNode.delegate = self
        collectionNode.view.delaysContentTouches = false
        
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = []
        
        refreshControl.reactive.controlEvents(.valueChanged).observeValues { [weak self] _ in
            guard let sself = self else { return }
            sself.refreshControl.beginRefreshing()
            sself.fetchContent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubnode(collectionNode)
        collectionNode.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        collectionNode.view.addSubview(refreshControl)
        fetchContent()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !(lastViewSize == view.bounds.size) {
            lastViewSize = view.bounds.size
            reloadContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension SectionViewController {
    func fetchContent() {
        guard exonyms.isEmpty || Date().timeIntervalSince(refreshTimestamp) > refreshTimeInterval else {
            isFetchingContent = false
            return
        }
        
        activityIndicatorView.startAnimating()
        WebServices().fetchAboutCanada { [weak self] result in
            guard let sself = self else { return }
            switch result {
            case .success (let canada):
                sself.exonyms = canada.exonyms.filter { element in
                    !(element.title == nil && element.description == nil && element.imageURL == nil)
                }
                DispatchQueue.main.async {
                    sself.title = canada.title
                    sself.reloadContent()
                }
            case .failure (let error):
                debugPrint("Fetch About Canada Error: \(error)")
            }
            
            DispatchQueue.main.async {
                sself.activityIndicatorView.stopAnimating()
            }
            sself.refreshTimestamp = Date()
            sself.isFetchingContent = false
        }
    }
}

private extension SectionViewController {
    func reloadContent() {
        let column = view.bounds.width < 650.0 ? 1 : view.bounds.width > view.bounds.height ? 3 : 2
        sectionAttributes = SectionAttributes.makeArticleGridLayoutWith(articles: exonyms.count, columns: column)
        collectionNode.reloadData()
        collectionNode.waitUntilAllUpdatesAreProcessed()
    }
}

extension SectionViewController: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return sectionAttributes.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return sectionAttributes[section].cellAttributes.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellAttributes = sectionAttributes.cellAttributes(at: indexPath)
        return { [weak self] in
            guard let sself = self, let index = cellAttributes.articleIndex else { return ASCellNode() }
            return SectionCellNode(exonym: sself.exonyms[index])
        }
    }
}

extension SectionViewController: SectionCollectionViewLayoutDelegate {
    var collectionViewSize: CGSize {
        return view.bounds.size
    }
    
    func collectionViewLayout(_ layout: SectionCollectionViewLayout, cellAttributesForItemAt indexPath: IndexPath) -> SectionCellAttributes {
        return sectionAttributes.cellAttributes(at: indexPath)
    }
    
    func collectionViewLayout(_ layout: SectionCollectionViewLayout, calculatedCellSizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionNode.nodeForItem(at: indexPath)?.calculatedSize ?? .zero
    }
    
    func collectionViewLayout(_ layout: SectionCollectionViewLayout, numberOfColumnsAt section: Int) -> Int {
        return sectionAttributes[section].numberOfColumns
    }
}
