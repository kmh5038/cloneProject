
//
//  ViewController.swift
//  Diary2
//
//  Created by 김명현 on 2023/08/17.
//

import UIKit

class ViewController: UIViewController {
    
    private var diaryList = [Diary]() {
        didSet {
            self.saveDiaryList()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        NotificationCenter.default.addObserver(self, selector: #selector(editDiaryNotification(_:)), name: NSNotification.Name("editDiary"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(starDiaryNotification(_:)), name: NSNotification.Name( "starDiary"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteDiaryNotification(_:)), name: Notification.Name("deleteDiary"), object: nil)
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // collectionView에 생기는 cell의 간격
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    

    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == diary.uuidString}) else { return }
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
        self.collectionView.reloadData()
    }
    
    
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList[index].isStar = isStar
        
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    //     일기작성화면이동은 segue로 이동하기 때문에 prepare 필요
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
                writeDiaryViewController.delegate = self
            }
        }

   
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    // 앱 꺼져도 저장되게
    private func saveDiaryList() {
        let date = self.diaryList.map {
            [
             "uuidString": $0.uuidString,
             "title": $0.title,
             "contents": $0.contents,
             "date": $0.date,
             "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
    }
    
    private func loadDiaryList() {
      let userDefaults = UserDefaults.standard
      guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
      self.diaryList = data.compactMap {
        guard let uuidString = $0["uuidString"] as? String else { return nil}
        guard let title = $0["title"] as? String else { return nil }
        guard let contents = $0["contents"] as? String else { return nil }
        guard let date = $0["date"] as? Date else { return nil }
        guard let isStar = $0["isStar"] as? Bool else { return nil }
        return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
      }
      self.diaryList = self.diaryList.sorted(by: {
        $0.date.compare($1.date) == .orderedDescending
      })
    }

    
    // Date타입이여서 dateFormmater로 String변환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
}

//    writeDiaryViewController에서 작성된 일기를 diaryList배열에 추가해줌


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    // collectionView에 지정된 위치에 표시할 cell을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)  // Date타입이여서 dateFormmater로 변환
        return cell
    }
}

// CollectionView Layout 설정
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
    
}

// 특정 셀이 선택됐음을 알리는 메서드, Cell 눌렀을때 detail로 이동

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          /* 1. viewController 정수에 DiaryDetailViewController의 정보를 넘겨줌
             2. diary 정수에 diaryList넘겨주기
             3. DiaryDetailViewController의 diary에 dayList 넘겨줌 */
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary // detail로 들어갔을때 내부 title, contents, date 표시
        viewController.indexPath = indexPath // 수정, 삭제할때 좌표지정
        // DiaryDetailViewController로 화면전환
        self.navigationController?.pushViewController(viewController, animated: true)
        
//        self.present(viewController, animated: true)  모달로 띄울때
    }
    
}

extension ViewController: WriteDiaryViewDelegate{
    func didSelectReigster(diary: Diary) {
        self.diaryList.append(diary)
      // 최신순으로 일기리스트 정렬
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
}
