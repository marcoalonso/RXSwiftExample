//
//  ViewController.swift
//  https://cocoapods.org/pods/RxSwift
//
//  Created by marco rodriguez on 30/06/22.
/*
 RXSwift
 ¿Qué es?, es un enfoque que trata con secuencias asíncronas de datos. Es decir, secuencias observables de elementos que emiten eventos a los observadores.
 
 
 */

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //estamos creando una secuencia de tipo Observable<String> usando el operador .of
        /// los objetos pueden suscribirse para recibir eventos de la secuencia
        /// El operador .of le permite crear la secuencia a partir de un tipo variable inferido. También puede usar: .just que crea una secuencia de un solo elemento, o .from que crea una secuencia a partir de una matriz
        
        
        let observableSequence = Observable.of("One", "Two", "Three", "Four", "65")
        
        /// cuando un objeto se suscribe a una secuencia, no está directamente haciendo referencia a ella. Por lo tanto, si no cancela manualmente sus suscripciones, puede correr el riesgo de perder memoria
        
        //la bolsa desechable contiene cualquier cantidad de objetos que se ajusten al protocolo Dispose, En su método deinit , la bolsa desechable pasa por cada uno de los objetos desechables y los elimina de la memoria.
        
        let disposeBag = DisposeBag()
        
        //el método .suscribe está suscribiendo un controlador de eventos a una secuencia observable
        /// en el cierre, especifica cómo desea manejar los diferentes eventos que emite la secuencia. En este caso, independientemente del tipo de evento, estamos imprimiendo el evento en la consola
        
        let subscription = observableSequence.subscribe({ (event: Event<String>) in
                        print(event)
                    })
        /*
         -next(Element) — cuando la secuencia itera sobre un elemento, enviará el siguiente evento, con el elemento como un valor asociado
         
         -error(Swift.Error) : cuando la secuencia encuentra un error, puede enviar el evento de error con el tipo de error como un valor asociado y finalizar la secuencia.
         
         -completado : cuando la secuencia haya terminado de iterar sobre cada elemento normalmente, emitirá el evento completado.
         */
        
        /// simplemente agrega la suscripción (de tipo Desechable) a la bolsa de disposición. Cuando se llega al final de este bloque de código, se llama al método deinit.
        ///
        subscription.disposed(by: disposeBag)
        
        /*
         /// En resumen: Se puede configurar una secuencia observable, suscribirse a esa secuencia con un controlador de eventos y deshacerse de la suscripción cuando haya terminado.
         
         let disposeBag = DisposeBag()

         Observable.of("One", "Two", "Three", "Four")

         .subscribe({
           print($0)
         })

         .disposed(by: disposeBag)
         */
        
    }


}

