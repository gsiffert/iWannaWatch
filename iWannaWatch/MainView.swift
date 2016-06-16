//
//  MainView.swift
//  iWannaWatch
//
//  Created by Gaston Siffert on 6/8/16.
//  Copyright © 2016 Gaston Siffert. All rights reserved.
//

import Cocoa

class MainView: NSViewController {

    @IBOutlet weak var tableView        : NSTableView!
    
    private let _episodeRequests    = EpisodesRequest()
    private var _shows              = [Show]()
    private var _show_cells         = [ShowCellView]()
    
    var delegate                    : IReachabilityDelegate?
    
    private var _timer              : NSTimer?
    private let _reachability       = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        startCheckNews()
    }
    
    private func clearGUI() {
        _shows = []
        _show_cells.removeAll()
        tableView.reloadData()
        tableView.layout()
    }
    
    @objc
    private func loadEpisodes() {
        _episodeRequests.get(onEpisodesSuccess, onErrors: onEpisodeFailed)
    }
    
    private func onEpisodesSuccess(shows: [Show]) {
        delegate?.isReachable()
        clearGUI()
        _shows      = shows.sort({ (first, second) -> Bool in
            return first.title < second.title
        })
        tableView.reloadData()
    }
    
    private func onEpisodeFailed(errors: [Error]) {
        if let error = errors.first {
            if error.code == 0 {
                delegate?.isUnreachable()
                startCheckReachability()
            }
        }
    }
}

extension MainView {
    
    private func startCheckNews() {
        _timer?.invalidate()
        _timer = NSTimer(timeInterval: 10 * 60, target: self, selector:
            #selector(MainView.loadEpisodes), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(_timer!, forMode: NSRunLoopCommonModes)
        loadEpisodes()
    }
    
    private func startCheckReachability() {
        _timer?.invalidate()
        _timer = NSTimer(timeInterval: 10, target: self, selector:
            #selector(MainView.checkReachability), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(_timer!, forMode: NSRunLoopCommonModes)
        checkReachability()
    }
    
    @objc
    private func checkReachability() {
        _reachability.Ping({
            self.delegate?.isReachable()
            self.startCheckNews()
        }) {
            self.delegate?.isUnreachable()
        }
    }
    
}

extension MainView: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _shows.count
    }
    
}

extension MainView: NSTableViewDelegate {
    
    private static let SHOW_CELL_IDENTIFIER = "show_cell"
    
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let height = 64 + _shows[row].unseen.count * (32 + 2 * 2)
        return CGFloat(height)
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if row == _show_cells.count {
            let cell = tableView.makeViewWithIdentifier(MainView.SHOW_CELL_IDENTIFIER, owner: nil) as! ShowCellView
            cell.show = _shows[row]
            _show_cells.append(cell)
        }
        
        return _show_cells[row]
    }
    
}