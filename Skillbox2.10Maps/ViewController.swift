//
//  ViewController.swift
//  Skillbox2.10Maps
//
//  Created by Артём on 2/8/21.
//

/*Для каждого типа карт сделайте следующие задания:
 
-показ самой карты на весь экран;
-показ пользователя;
-показ пяти точек (POI) с достопримечательностями в вашем городе (достопримечательности — на ваш выбор), с разными иконками;
-центрирование карты на эти пять точек;
-обработку нажатия на точки: при нажатии нужно выводить в консоль название достопримечательности, на которую нажали;
-кнопки «+» и «−», по нажатию на которые карта соответственно приближается или отдаляется;
-кнопку center, по нажатию на которую карта центруется на позицию пользователя.*/




import UIKit
import MapKit

class ViewController: UIViewController {
    
    private let places: [Place] = [
        Place(name: "Площадь Ленина", imageName: "плленина", coordinate: CLLocationCoordinate2D(latitude: 48.480190, longitude: 135.071926)),
        Place(name: "Амурский мост", imageName: "мост", coordinate: CLLocationCoordinate2D(latitude: 48.536123, longitude: 135.000341)),
        Place(name: "Утёс", imageName: "утес", coordinate: CLLocationCoordinate2D(latitude: 48.472635, longitude: 135.049272)),
        Place(name: "Комсомольская площадь", imageName: "комспл", coordinate: CLLocationCoordinate2D(latitude: 48.471999, longitude: 135.057500)),
        Place(name: "Площадь Славы", imageName: "плславы", coordinate: CLLocationCoordinate2D(latitude: 48.466636, longitude: 135.065236))
    ]

    @IBOutlet weak var mapView: MKMapView!
//    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        addMapTrackingButton()
        let lm = LocationManager.shared
        lm.requestAccess { (isSuccess) in
            if isSuccess{
                lm.getLocation { (location) in
                    print("user location: \(String(describing: location))")
                }
            }
        }
        
        mapView.delegate = self
        placeAnn()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    
    func placeAnn(){
        for i in places {
            let annotation = MKPointAnnotation()
            annotation.coordinate = i.coordinate
            annotation.title = i.name
            mapView.addAnnotation(annotation)
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let center = centerOfCoordinates(in: places)
        print(center)
        let regionRadius: CLLocationDistance = 8000
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
    }
    
    
    func degreesToRadians(degrees: CLLocationDegrees) -> Double {
        return degrees * .pi / 180
    }

    func radiansToDegrees(radians: Double) -> CLLocationDegrees {
        return radians * 180 / .pi
    }
    
    func centerOfCoordinates(in coordinates: [Place]) -> CLLocationCoordinate2D {
        var xCenter: Double = 0
        var yCenter: Double = 0
        var zCenter: Double = 0

        for i in 0..<coordinates.count {

            //convert to radians
            let coord = coordinates[i]
            let latRadians = degreesToRadians(degrees: coord.coordinate.latitude)
            let lngRadians = degreesToRadians(degrees: coord.coordinate.longitude)

            //convert to cartesian (x,y,z) coordinates
            let x: Double = cos(latRadians) * cos(lngRadians)
            let y: Double = cos(latRadians) * sin(lngRadians)
            let z = sin(latRadians)

            xCenter = xCenter + x
            yCenter = yCenter + y
            zCenter = zCenter + z
        }

        //averaged cartesian coordinate
        xCenter = xCenter / Double(places.count)
        yCenter = yCenter / Double(places.count)
        zCenter = zCenter / Double(places.count)

        let lngCenterRadians = atan2(yCenter, xCenter)
        let hyp = sqrt(pow(xCenter, 2) + pow(yCenter, 2))
        let latCenterRadians = atan2(zCenter, hyp)

        let latCenter = radiansToDegrees(radians: latCenterRadians)
        let lngCenter = radiansToDegrees(radians: lngCenterRadians)
        return CLLocationCoordinate2DMake(CLLocationDegrees(latCenter), CLLocationDegrees(lngCenter))
    
    }
    
    func addMapTrackingButton(){
        let image = UIImage(named: "myloc") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.frame = CGRect(origin: CGPoint(x:340, y: 640), size: CGSize(width: 50, height: 50))
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(ViewController.centerMapOnUserButtonClicked), for:.touchUpInside)
        mapView.addSubview(button)
    }

    @objc func centerMapOnUserButtonClicked() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation { return nil }
//        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        
        
//        var images = [String]()
//        for place in places{
//            images.append(place.imageName)
//        }
//        annotationView.image = UIImage(named: images[currentIndex])
//        self.currentIndex = self.currentIndex + 1
        
        switch annotation.title!! {
            case "Площадь Ленина":
                annotationView.markerTintColor = UIColor.black
                annotationView.glyphImage = UIImage(named: "парк")
            case "Амурский мост":
                annotationView.markerTintColor = UIColor.brown
                annotationView.image = UIImage(named: "мост")
            case "Утёс":
                annotationView.markerTintColor = UIColor.systemPink
                annotationView.image = UIImage(named: "утес")
            case "Комсомольская площадь":
                annotationView.markerTintColor = UIColor.blue
                annotationView.image = UIImage(named: "комспл")
            case "Площадь Славы":
                annotationView.markerTintColor = UIColor.green
                annotationView.image = UIImage(named: "плславы")
            default:
                annotationView.markerTintColor = UIColor(red: (146.0/255), green: (187.0/255), blue: (217.0/255), alpha: 1.0)
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        if let annotationTitle = view.annotation?.title {
            print("User tapped on: \(annotationTitle!)")
        }
    }
}


class Place: NSObject, MKAnnotation{
    var name: String
    var imageName: String
    var coordinate: CLLocationCoordinate2D
    
    
    init(name: String, imageName: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.name = name
        self.imageName = imageName
    }
}

