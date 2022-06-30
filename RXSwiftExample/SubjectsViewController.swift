//
//  SubjectsViewController.swift
//  RXSwiftExample
// https://medium.com/swift2go/rxswift-part-2-working-with-subjects-34e35a058a2c
//  Created by marco rodriguez on 30/06/22.
// Cambios importantes: https://freak4pc.medium.com/whats-new-in-rxswift-5-f7a5c8ee48e7

/*
 Un sujeto es un tipo reactivo que es tanto una secuencia observable como un observador. Pueden aceptar suscripciones y emitir eventos, así como agregar nuevos elementos a la secuencia.
 Hay cuatro tipos de asunto: PublishSubject , BehaviorSubject , Relay(Variable), ReplaySubject
 
 Hay tambien dos términos son esenciales; -Replay & -Stop Event
 Replay: en algunos casos, es posible que desee que un nuevo suscriptor reciba los eventos next() más recientes de la secuencia a la que se está suscribiendo. Aunque el o los eventos ya hayan sido emitidos, el sujeto puede almacenarlos y emitirlos nuevamente a un solo suscriptor en el momento de la suscripción.
 Stop Event: este es un evento que finaliza una secuencia, ya sea completada() o error()
 
 
 */

    ///PublishSubject:  solo se ocupa de emitir nuevos eventos a sus suscriptores. No reproduce los eventos next(), por lo que el suscriptor no recibirá ninguno de los que existían antes de la suscripción. i te suscribes a una secuencia que ya ha sido cancelada, el suscriptor recibirá esa información. Vale la pena señalar que todos los tipos de sujetos vuelven a emitir StopEvents().

    ///BehaviorSubject: almacena el evento next() más reciente, que se puede reproducir para los nuevos suscriptores, un nuevo suscriptor puede recibir el evento next() más reciente incluso si se suscribe después de que se emitió el evento.  No debe tener un búfer vacío, por lo que se inicializa con un valor inicial que actúa como el evento next() inicial, este valor se sobrescribe tan pronto como se agrega un nuevo elemento a la secuencia.


    ///Relay: es un envoltorio alrededor de BehaviorSubject que permite un manejo más simple, proporciona una sintaxis de puntos para obtener y establecer un valor único que se emite como un evento next() y se almacena para su reproducción.   La propiedad .value expuesta obtiene y establece el valor en una propiedad _value almacenada de forma privada.   también tiene un método .asObservable() que devuelve el BehaviorSubject privado para administrar sus suscriptores.
        
        //No permiten la terminación anticipada. En otras palabras, no puede enviar un evento de error() o complete() para terminar la secuencia. Simplemente espere a que se desasigne la variable y finalice la secuencia en su método deinit.


    ///ReplaySubject:  le brinda la posibilidad de reproducir muchos eventos próximos, especifica el tamaño de su búfer cuando crea una instancia de ReplaySubject, y mantiene sus próximos eventos más recientes hasta el límite del búfer. Cuando se agrega un nuevo suscriptor, los eventos almacenados en el búfer se reproducen uno tras otro como si estuvieran ocurriendo en rápida sucesión inmediatamente después de la suscripción. Una vez más, los eventos de parada se vuelven a emitir a los nuevos suscriptores.

import UIKit
import RxSwift
import RxCocoa

class SubjectsViewController: UIViewController {
    
    enum MyError: Error {
        case error1
        case error2
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        PublishedSubjectExample()
//        BehaviorSubjectExample()
//        VariableExample()
        ReplaySubjetExample()
        
    }
    
    func ReplaySubjetExample(){
        let disposeBag = DisposeBag()
                    
        let replaySub = ReplaySubject<String>.create(bufferSize: 3)
        //Imprime los ultimos 3 eventos almacenados en el buffer, como son 5 solo imprime los eventos 3-5
                    
        replaySub.on(.next("(pre) Event 1"))
        replaySub.on(.next("(pre) Event 2"))
        replaySub.on(.next("(pre) Event 3"))
        replaySub.on(.next("(pre) Event 4"))
        replaySub.on(.next("(pre) Event 5")) //5 events overfills the buffer
                    
        replaySub.subscribe({ //replays the 4 events in memory (2-5)
          print("line: \(#line)", "event: \($0)")
        })
        .disposed(by: disposeBag)
                    
        replaySub.on(.next("(post) Event 6")) //emits next event to subscription
                    
        replaySub.onError(MyError.error2) //emits error event and terminates the sequence
                    
        replaySub.on(.next("(post) Event 7")) //sequence cannot emit event as it has been terminated

    }
    
    func VariableExample(){
        let disposeBag = DisposeBag()
        let relay = BehaviorRelay(value: "starting value") //instantiate variable with starting value
                    
        relay.asObservable().subscribe({ //asObservable() returns the BehaviorSubject which is held as a property. Sequence replays "starting value" to Sub A
          print("Sub A, line: \(#line)", "event: \($0)")
        })
        .disposed(by: disposeBag)
              
        relay.accept("Siguiente Evento 1") // gets and sets to a privately stored property. Additionally, creates a next() event on the privately stored BehaviorSubject
        relay.asObservable().subscribe({ //Sequence replays "next 1" to Sub B
          print("Sub B, line: \(#line)", "event: \($0)")
        })
        .disposed(by: disposeBag)

        print("RelayValue: \(relay.value)") //emits "next 2" to both Sub A and Sub B
    
    }
    
    func PublishedSubjectExample(){
        
        let disposeBag = DisposeBag()
                    
        let pubSubj = PublishSubject<String>()
                    
        pubSubj.on(.next("(next 1")) //event emitted to no subscribers
                    
        pubSubj.subscribe({ //subscriber added, but no replay of "next 1"
                        print("line: \(#line),", "event: \($0)")
                    })
        .disposed(by: disposeBag)
                    
        pubSubj.on(.next("(next 2")) //event emitted and received by subscriber
        pubSubj.onError(MyError.error1) //emits error and terminates sequence
                    
        pubSubj.on(.next("next 3")) //pubSubj cannot emit this event
    }
    
    func BehaviorSubjectExample(){
        let dispose = DisposeBag()
                    
        let behavSub = BehaviorSubject<String>(value: "Starting value") //BehaviorSubject instantiated with a starting value (single event buffer)
                    
        behavSub.subscribe({ (event) in //Sub A added and most recent event replayed ("starting value")
           print("Sub A, line: \(#line)", "event: \(event)")
        })
        .disposed(by: dispose)
                    
        behavSub.on(.next("next 1")) //event emitted and received by Sub A. Value ("next 1") stored for replay
                    
        behavSub.subscribe({ (event) in //Sub B added and most recent event replayed ("next 1")
        print("Sub B, line: \(#line)", "event: \(event)")
        })
        .disposed(by: dispose)
                    
        behavSub.on(.next("next 2")) //event emitted to Sub A and Sub B. Value ("next 2") stored for replay
                    
        behavSub.onCompleted() //emits completed event and terminates sequence
    }

}
