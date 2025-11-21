//
//  CaptchaView.swift
//  captcha_swift
//
//  Created by kean_qi on 2020/4/29.
//  Copyright © 2020 kean_qi. All rights reserved.
//

import UIKit
import RxSwift
/// 屏幕的宽
let SCREENW = UIScreen.main.bounds.size.width
/// 屏幕的高
let SCREENH = UIScreen.main.bounds.size.height

let sliderHeight:CGFloat = 40

/// 弹窗边距
let contentViewMargin: CGFloat = 40

let contentWidth = SCREENW - 2 * contentViewMargin
/// 内容边距
let containerMargin: CGFloat = 16

/// 校验模式
public enum CaptchaType: String {
    case puzzle     = "blockPuzzle"  //"滑动拼图"
    case clickword  = "clickWord" //"字符校验"
}

/// 状态模式
enum CaptchaResult{
    case normal
    case progress
    case success
    case failure
}


public protocol CaptchaViewProtocol: NSObjectProtocol {
    var title: String { get }
    var sliderDes: String { get }
    var success: String { get }
    var fail: String { get }
}


public class CaptchaView: UIView {

    var completeBlock: ((String) -> Void)?
    var currentType = CaptchaType.puzzle
    //滑动拼图状态
    var currentPuzzleResultType = CaptchaResult.normal
    //字符校验状态
    var currentClickwordResultType = CaptchaResult.normal

    var repModel = CaptchaModel(){
        didSet {
            baseImageView.image = base64ConvertImage(repModel.originalImageBase64)
            puzzleImageView.image = base64ConvertImage(repModel.jigsawImageBase64)
        }
    }
    
    //底层ImageView
    var baseImageView = UIImageView()
    //拼图ImageView
    var puzzleImageView = UIImageView()
    //刷新按钮
    let refreshBtn      = UIButton()

    // ======== 通用视图相关 ========
    let contentView     = UIView() // 容器视图
    let topView         = UIView()
    
    var needEncryption = false;
    var scale = 1.0
    let disposeBag = DisposeBag()
    //========puzzle============
    //滑块父view
    let sliderView = UIView()
    let sliderTrackView      = UIView()
    let sliderBgColor   = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
    //滑动过程颜色view
    let progressView = UIView()
    
    lazy var activityView: UIActivityIndicatorView = {
        var style = UIActivityIndicatorView.Style.large
        let ac = UIActivityIndicatorView(style: style)
        ac.color = .white_ff
        return ac
    }()
    //推动view
    let thumbView = UIImageView(image: bundleImage("icon_captcha_slider"))
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let margin       = CGFloat(0.1) // 默认边距
    var puzzleThumbOffsetX: CGFloat {
        get {
            return margin
        }
    }
    //最后点击点
    var lastPointX = CGFloat.zero
    var offsetXList: Set<CGFloat> = [] // 滑动为匀速时,判定为机器操作,默认失败
    
    
    //mark:显示
    public class func show(completeBlock block: @escaping ((String) -> Void)){
        let view = CaptchaView(frame: UIScreen.main.bounds)
        view.completeBlock = block
        UIApplication.shared.windows[0].addSubview(view)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        _initView()
        //滑块图片
        baseImageView.addSubview(puzzleImageView)
        requestData()
        
    }
    
    
    /// 请求接口
    @objc func requestData(){
        activityView.startAnimating()
        CaptchaService.getCaptcha(currentType).request.subscribe(onSuccess: { [weak self] json in
            guard let self = self else { return }
            guard let model = try? JSONDecoder().decode(CaptchaModel.self, from: JSONSerialization.data(withJSONObject: json)) else { return }
            activityView.stopAnimating()
            repModel = model
            //secretKey有值 代表需要进行加密
            needEncryption = !repModel.secretKey.isEmpty
            getRequestView(currentType)
        }, onFailure: { [weak self] _ in
            guard let self = self else { return }
            activityView.stopAnimating()
            close()
        }).disposed(by: disposeBag)
        
    }
    /// 刷新初始化数据
    func getRequestView(_ type: CaptchaType){
        sliderView.subviews.forEach {$0.removeFromSuperview()}
        _initPuzzleFrame()
    }
    
    /// 请求校验接口
    func requestCheckData(pointJson: String = "", token: String, pointStr: String){
        activityView.startAnimating()
        CaptchaService.checkCaptcha(currentType, pointJson: pointJson, token: token).request.subscribe(onSuccess: {[weak self] json in
            guard let self = self else { return }
            activityView.stopAnimating()
            var successStr = "\(token)---\(pointStr)";
            if(self.repModel.secretKey.count > 0){
                successStr = ESConfig.aesEncrypt(successStr, self.repModel.secretKey)
            }
            self.showResult(true, successStr: successStr)
        }, onFailure: { [weak self] _ in
            guard let self = self else { return }
            activityView.stopAnimating()
            showResult(false, successStr: "")
        }).disposed(by: disposeBag)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 关闭当前页面
    @objc func close() {
        if let block = completeBlock {
            block("")
        }
        removeFromSuperview()
    }
    
    @objc func closeWithHandle() {
        removeFromSuperview()
    }

    // 刷新
    @objc func refresh() {
        requestData()
    }

    

    
    /// 校验结果
    func checkResult(_ point:CGPoint){
        var pointJson = "";
        let pointEncode = ESConfig.jsonEncode(CaptchaRequestModel(x: point.x/scale, y: 5))
        //请求数据有secretKey 走加密  否则不走加密
        if(self.needEncryption){
            pointJson = ESConfig.aesEncrypt(pointEncode, self.repModel.secretKey)
        } else {
            pointJson = pointEncode;
        }
        requestCheckData(pointJson: pointJson, token: self.repModel.token, pointStr: pointEncode)
        
    }
    
    /// 显示结果页
    ///
    /// - Parameter isSuccess: 是否正确
    /// - note: 暂时只有错误时,才显示
    func showResult(_ isSuccess: Bool, successStr: String) {
        if isSuccess {
            completeBlock?(successStr)
            setCurrentPuzzleResultType(CaptchaResult.success)
            removeFromSuperview()
            TTRequestManager.shared.delegate?.captchaSuccessHandle()
        } else {
            self.setCurrentPuzzleResultType(CaptchaResult.failure)
            
            UIView.animate(withDuration: 0.75, animations: {
                self.thumbView.transform = .identity
                self.puzzleImageView.transform = .identity
            }) { (finish) in
                self.setCurrentPuzzleResultType(CaptchaResult.normal)
                self.refresh()
            }
        }
    }

}

extension CaptchaView {
    
    func _initView(){
        contentView.backgroundColor = .white_ff
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowColor = UIColor("000000",0.04).cgColor
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOpacity = 1
        //容器view
        addSubview(contentView)
        
        contentView.layer.cornerRadius = 12
//        contentView.layer.masksToBounds = true
        //顶部导航view
        createTopView()
        
        contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - contentViewMargin * 2, height: 310)
        contentView.center  = center
        
        baseImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        baseImageView.clipsToBounds = true
        baseImageView.frame = CGRect(x: containerMargin , y: topView.frame.maxY + 12, width: contentWidth - 2 * containerMargin, height: 131)
        refreshBtn.setImage(bundleImage("icon_captcha_refresh"), for: .normal)
        refreshBtn.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        // 滑块view
        createSliderView()
        activityView.frame = contentView.bounds
        contentView.addSubview(activityView)
    }
    
    func createTopView() {
        let tipLabel = UILabel()
        tipLabel.frame = CGRect(x: containerMargin, y: 12, width: 200, height: 26)
        tipLabel.text = TTRequestManager.shared.captchaDelegate?.title
        tipLabel.adjustsFontSizeToFitWidth = true
        tipLabel.textColor = UIColor("9DA2AD")
        tipLabel.font = .systemFont(ofSize: 15)
        topView.addSubview(tipLabel)
        
        let closeButton = UIButton()
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.frame = CGRect(x: contentWidth - 40, y: 12, width: 28, height: 28)
        closeButton.backgroundColor = UIColor("F5F6FB")
        closeButton.layer.cornerRadius = 14
        closeButton.layer.masksToBounds = true
        closeButton.setImage(bundleImage("icon_captcha_close"), for: .normal)
        topView.addSubview(closeButton)
        
        let titleLabel = UILabel()
        titleLabel.text = TTRequestManager.shared.captchaDelegate?.sliderDes
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = UIColor("1E222B")
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.frame = CGRect(x: containerMargin, y: tipLabel.frame.maxY + 4, width: contentWidth - 2 * containerMargin, height: 26)
        topView.frame = CGRect(x: 0, y: 0, width: width, height: titleLabel.frame.maxY)
        topView.addSubview(titleLabel)
    }
    
    
    func createSliderView() {
        sliderTrackView.frame = CGRect(x: 0, y: 16, width: baseImageView.width, height: 8)
        sliderTrackView.layer.cornerRadius = 4
        sliderTrackView.layer.masksToBounds = true
        sliderTrackView.backgroundColor = UIColor("ECEDF4")
        sliderView.addSubview(sliderTrackView)
        sliderView.addSubview(thumbView)
        thumbView.isUserInteractionEnabled = true
        thumbView.backgroundColor = .clear
        let pan = UIPanGestureRecognizer(target: self, action: #selector(slidThumbView(sender:)))
        thumbView.addGestureRecognizer(pan)
    }
    
    func base64ConvertImage(_ imgStr: String ) -> UIImage{
        let data = Data.init(base64Encoded: imgStr, options: .ignoreUnknownCharacters)
        let img = UIImage(data: data!)
        return img ?? UIImage()
    }

}

//拼图校验视图
extension CaptchaView {
    /// 初始化拼图校验视图
    func _initPuzzleFrame(){
        //图片左边
        let baseImg = base64ConvertImage(repModel.originalImageBase64)
        let imageViewWidth = contentWidth - containerMargin * 2
        scale = imageViewWidth/baseImg.size.width
        let imageViewHeight = scale * baseImg.size.height
        baseImageView.frame = CGRect(x: containerMargin, y: topView.frame.maxY + CGFloat(12), width: imageViewWidth, height: imageViewHeight)
        let puzzleImg = base64ConvertImage(repModel.jigsawImageBase64)
        let puzzleImageViewHeight = scale * puzzleImg.size.width
        puzzleImageView.frame = CGRect(x: 0, y: 0, width: puzzleImageViewHeight, height: imageViewHeight)
        //底部view坐标
        sliderView.frame = CGRect(x: baseImageView.frame.minX, y: baseImageView.frame.maxY + 12, width: baseImageView.frame.size.width, height: sliderHeight)

        thumbView.frame = CGRect(x: puzzleThumbOffsetX, y: 4, width: 48, height: 32)
        statusLabel.frame = CGRect(x: containerMargin, y: sliderView.frame.maxY, width: 150, height: 32)
        refreshBtn.frame = CGRect(x: contentWidth - containerMargin - 32, y: sliderView.frame.maxY, width: 32, height: 32)
        contentView.bounds.size.height = refreshBtn.frame.maxY + 12
        activityView.frame = contentView.bounds
        contentView.addSubview(topView)
        contentView.addSubview(baseImageView)
        sliderView.addSubview(sliderTrackView)
        sliderView.addSubview(thumbView)
        contentView.addSubview(sliderView)
        contentView.addSubview(refreshBtn)
        contentView.addSubview(statusLabel)
        contentView.bringSubviewToFront(activityView)
    }
    
    /// 滑动进度条的手势事件
    ///
    /// - Parameter sender: 滑动的手势对象
    @objc func slidThumbView(sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: sliderView)
        if lastPointX != .zero {
            let offetX  = point.x - lastPointX
            offsetXList.insert(offetX)
        }
        lastPointX = point.x
        thumbView.transform = CGAffineTransform(translationX: min(max(point.x, 0), sliderView.bounds.width - thumbView.bounds.width), y: 0)
        puzzleImageView.transform = CGAffineTransform(translationX: min(max(point.x, 0), sliderView.bounds.width - puzzleImageView.bounds.width), y: 0)
        if(sender.state == UIGestureRecognizer.State.ended){
            offsetXList.remove(0)
            checkResult(point)
        }
    }
    
    //滑动验证码状态修改  如果需要图片可自行修改
    func setCurrentPuzzleResultType(_ currentPuzzleType: CaptchaResult){
        currentPuzzleResultType = currentPuzzleType
        switch currentPuzzleResultType {
        case .normal,
            .progress:
            statusLabel.isHidden = true
            break
        case .success:
            // ✓
            statusLabel.isHidden = false
            statusLabel.text = TTRequestManager.shared.captchaDelegate?.success
            statusLabel.textColor = .green_2a
            break
        case .failure:
            // X
            statusLabel.isHidden = false
            statusLabel.text = TTRequestManager.shared.captchaDelegate?.fail
            statusLabel.textColor = .red_1b
            break
        }
    }
    
   
}

/// 延时主线程执行
func t_delay(_ seconds: Double = 2, closure: @escaping () -> ()) {
    let _t = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: _t, execute: closure)
}
