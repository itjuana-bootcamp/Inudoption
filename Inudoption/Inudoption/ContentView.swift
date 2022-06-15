//
//  ContentView.swift
//  Inudoption
//
//  Created by Martin García on 6/15/22.
//

import SwiftUI
struct User: Hashable, CustomStringConvertible {
    var id: Int
    let firstName: String
    let secondName: String
    let age: Int
    let mutualFriends: Int
    let imageName: String
    let occupation: String

    var description: String {
        "\(firstName), id: \(id)"
    }
}

struct ContentView: View {
    @State var users: [User] = [
        User(id: 0, firstName: "Michael", secondName: "0", age: 27, mutualFriends: 0, imageName: "michael", occupation: "Judge"),
        User(id: 1, firstName: "Michael", secondName: "1", age: 27, mutualFriends: 0, imageName: "michael", occupation: "Judge"),
        User(id: 2, firstName: "Michael", secondName: "2", age: 27, mutualFriends: 0, imageName: "michael", occupation: "Judge"),
        User(id: 3, firstName: "Michael", secondName: "3", age: 27, mutualFriends: 0, imageName: "michael", occupation: "Judge"),
        User(id: 4, firstName: "Michael", secondName: "4", age: 27, mutualFriends: 0, imageName: "michael", occupation: "Judge")
    ]

    private func getCardWidth(with geometry: GeometryProxy, id: Int) -> CGFloat {
        geometry.size.width - CGFloat(users.count - 1 - id) * 10
    }

    private func getCardOffset(with geometry: GeometryProxy, id: Int) -> CGFloat {
        CGFloat(users.count - 1 - id) * 10
    }

    private var maxID: Int {
        users.map { $0.id }.max() ?? 0
    }

    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Say hi to your new friend"
        content.subtitle = "Launch app to connect with doggie"
        content.sound = .defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5
                                                        , repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func registerForRemoteNotification(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .criticalAlert, .badge]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(self.users, id: \.self) { user in
                    if (self.maxID - 3)...self.maxID ~= user.id {
                        CardView(with: user, onRemove: { removedUser in
                            self.users.removeAll { $0.id == removedUser.id }
                        })
                        .animation(.spring())
                            .frame(width: getCardWidth(with: geometry, id: user.id),
                                   height: 400)
                            .offset(x: 0, y: getCardOffset(with: geometry, id: user.id))
                    }
                }
            }
        }
        .onAppear {
            registerForRemoteNotification { flag in
                print("The user registered for remote notifications")
                if flag {
                    print("Scheduling alert...")
                    scheduleLocalNotification()

                }
            }
        }
    }
}

struct CardView: View {
    @State private var translation: CGSize = .zero

    private var user: User
    private var onRemove: (_ user: User) -> Void

    init(with user: User, onRemove: @escaping (_ user: User) -> Void) {
        self.user = user
        self.onRemove = onRemove
    }

    private var thresholdPercentage: CGFloat = 0.5

    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Image(user.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.75)
                    .clipped()
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(user.firstName) \(user.secondName), \(user.age)")
                            .font(.title)
                            .bold()
                        Text(user.occupation)
                            .font(.subheadline)
                            .bold()
                        Text("\(user.mutualFriends) Mutual Friends")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .background(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .animation(.interactiveSpring())
            .offset(x: self.translation.width, y: 0)
            .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                    }.onEnded { value in
                        if abs(getGesturePercentage(geometry, from: value)) > thresholdPercentage {
                            self.onRemove(user)
                        } else {
                            self.translation = .zero
                        }
                    }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
