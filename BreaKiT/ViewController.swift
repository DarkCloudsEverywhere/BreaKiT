// BreaKiT

//Created by Kimon

// Use Simulation Settings: iPad Pro 12.9 inch (5th Generation) in Portrait Mode

import UIKit
import AudioKit
import SoundpipeAudioKit
import AVFAudio

class ViewController: UIViewController {
    
    var file : AVAudioFile!
    var player : PhaseLockedVocoder!
    var player2 : AudioPlayer!
    var engine = AudioEngine()
    var filter : ThreePoleLowpassFilter!
    var timer : Timer!
    var buttonTimer: Timer!
    var currrentHead : Float!
    var ongoingHead : Float = 0.0
    
    
    //the player head slider
    @IBOutlet weak var head: UISlider!
    
    
    //connecting the slider with the player head
    @IBAction func headAction(_ sender: UISlider) {
        player.position = sender.value
    }
    
    //each button loops the sample for a corresponding time division
    @IBAction func setPosition(_ sender: UIButton) {
        currrentHead = head.value
        
        switch sender.tag{
            
            // T stands for triplets, D for dotted
            
        case 0: // 1/4
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.364, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 1: // 1/8
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.182, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 2: // 1/16
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.091, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 3:  // 1/32
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.045, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 4:  // 1/64
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.023, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 5:  // 1/4T
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.364 * 0.33, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 6:  // 1/8T
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.182 * 0.33, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 7:  // 1/16T
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.091 * 0.33, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 8:  // 1/32T
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.045 * 0.33, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 9:  // 1/64T
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.023 * 0.33, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 10:  // 1/4D
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.364 * 1.5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 11:  // 1/8D
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.182 * 1.5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 12:  // 1/16D
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.091 * 1.5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 13:  // 1/32D
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.045 * 1.5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        case 14:  // 1/64D
            buttonTimer = Timer.scheduledTimer(timeInterval: 0.023 * 1.5, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
        default:
            break
        }
        RunLoop.current.add(buttonTimer, forMode: .commonModes)
    }
    
    
    // release resumes the head in it's uninterrupted position
    @IBAction func unsetPosition(_ sender: UIButton) {
        buttonTimer.invalidate()
        head.setValue(ongoingHead, animated: false)
    }
    
    
    // the buttons array
    @IBOutlet var repeatButtons: [UIButton]!
    
    @IBOutlet weak var freqCutoffOutlet: UISlider!
    
    // filter cutoff slider
    @IBAction func filterCutoff(_ sender: UISlider) {
        if (filter.cutoffFrequency < 100){
            filter.cutoffFrequency = 100
        }
        filter.cutoffFrequency = sender.value
    }
    
    // switch on/off
    @IBAction func onOff(_ sender: UISwitch) {
        if (sender.isOn){
            for item in repeatButtons{
                item.isHidden = false
            }
            head.isHidden = false
            freqCutoffOutlet.isHidden = false
            player.start()
            player2.start()
        }
        else{
            for item in repeatButtons{
                item.isHidden = true
            }
            head.isHidden = true
            freqCutoffOutlet.isHidden = true
            player.stop()
            player2.stop()
        }
    }
    
    
    func assignSliderRange(){
        head.minimumValue = 0.0
        head.maximumValue = Float(file.duration)
    }
    
    
    // the function for the button timer
    @objc func loop(){
        head.setValue(currrentHead, animated: false)
    }
    
    
    
    
    func setupFile() -> AVAudioFile{
        let fileURL = Bundle.main.url(
            forResource: "cw_amen02_165",
            withExtension: "wav")
        
        file = try! AVAudioFile(forReading: fileURL!)
        
        return file
    }
    
    
    // the function for the drum sample playback, assuring an extra head keeps looping independently of the loop buttons, to sync the position with the release of the buttons
    @objc func incrementOffset(){
        
        head.setValue(head.value + 0.001, animated: false)
        player.position = head.value
        ongoingHead += 0.001
        if (head.value == Float(file.duration)){
            ongoingHead = 0
            head.setValue(ongoingHead, animated: false)
            player.position = ongoingHead
        }
    }
    
    
    func configureUI(){
        for item in repeatButtons{
            item.layer.cornerRadius = 10
            item.layer.shadowColor = UIColor.systemPink.cgColor
            item.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            item.layer.shadowRadius = 1.0
            item.layer.shadowOpacity = 0.5
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        head.isContinuous = false
        configureUI()
        file = setupFile()
        assignSliderRange()
        
        let filePath = Bundle.main.path(forResource: "pad2.wav", ofType: nil)
        let fileURL = URL(fileURLWithPath: filePath!)
        player2 = AudioPlayer(url:fileURL, buffered: true)
        player2.isLooping = true
        
        // the drum sample player
        player = PhaseLockedVocoder(file: file)
        
        
        player.pitchRatio = 1
        player.amplitude = 0.65
        
        
        let reverb = Reverb(player2)
        reverb.dryWetMix = 0.65
        
        filter = ThreePoleLowpassFilter(player, distortion: 0.5, cutoffFrequency: 10000, resonance: 0.35)
        
        let mixer = Mixer(filter, reverb)
        engine.output = mixer
        player.stop()
        player2.stop()
        try!engine.start()
//        player.start()
//        player2.start()
        
        //the timer for continuously looping the drum sample
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(incrementOffset), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: .commonModes)
       
        
        
        
    }
    
}


