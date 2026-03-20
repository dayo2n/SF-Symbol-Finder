//
//  SymbolCategory.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/20/26.
//

import Foundation

enum SymbolCategory: String, CaseIterable {
    case all
    case communication
    case weather
    case human
    case nature
    case devices
    case transportation
    case gaming
    case arrows
    case media
    case editing
    case commerce
    case health
    case objects
    case shapes

    var displayName: String {
        switch self {
        case .all: return String.categoryAll
        case .communication: return String.categoryCommunication
        case .weather: return String.categoryWeather
        case .human: return String.categoryHuman
        case .nature: return String.categoryNature
        case .devices: return String.categoryDevices
        case .transportation: return String.categoryTransportation
        case .gaming: return String.categoryGaming
        case .arrows: return String.categoryArrows
        case .media: return String.categoryMedia
        case .editing: return String.categoryEditing
        case .commerce: return String.categoryCommerce
        case .health: return String.categoryHealth
        case .objects: return String.categoryObjects
        case .shapes: return String.categoryShapes
        }
    }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .communication: return "message"
        case .weather: return "cloud.sun"
        case .human: return "person"
        case .nature: return "leaf"
        case .devices: return "desktopcomputer"
        case .transportation: return "car"
        case .gaming: return "gamecontroller"
        case .arrows: return "arrow.right"
        case .media: return "play"
        case .editing: return "pencil"
        case .commerce: return "cart"
        case .health: return "heart"
        case .objects: return "archivebox"
        case .shapes: return "circle"
        }
    }

    private var keywords: [String] {
        switch self {
        case .all: return []
        case .communication: return [
            "message", "phone", "envelope", "mail", "bubble", "call",
            "video", "mic", "speaker", "antenna", "wifi", "teletype",
            "megaphone", "bell", "chat"
        ]
        case .weather: return [
            "cloud", "sun", "moon", "rain", "snow", "wind", "bolt",
            "thermometer", "humidity", "tornado", "tropicalstorm",
            "hurricane", "snowflake", "fog", "haze", "sunrise", "sunset"
        ]
        case .human: return [
            "person", "figure", "hand", "face", "eye", "ear", "nose",
            "mouth", "brain", "accessibility", "body", "head", "foot",
            "arm", "leg", "thumb"
        ]
        case .nature: return [
            "leaf", "tree", "flower", "ant", "ladybug", "fish", "bird",
            "tortoise", "hare", "cat", "dog", "pawprint", "flame",
            "drop", "mountain", "globe", "water", "fossil", "carrot"
        ]
        case .devices: return [
            "desktopcomputer", "laptop", "keyboard", "display", "tv",
            "iphone", "ipad", "applewatch", "airpod", "homepod",
            "printer", "server", "cpu", "memorychip", "battery",
            "power", "plug", "cable", "sensor", "chip", "monitor",
            "headphones", "airplay", "computermouse", "magicmouse",
            "macbook", "macmini", "macpro", "appletv", "visionpro"
        ]
        case .transportation: return [
            "car", "bus", "tram", "bicycle", "scooter", "airplane",
            "ferry", "train", "road", "fuelpump", "steeringwheel",
            "engine", "gauge", "parkingsign", "ev"
        ]
        case .gaming: return [
            "gamecontroller", "dpad", "joystick", "playstation",
            "xbox", "logo.playstation", "logo.xbox", "trophy",
            "medal", "flag.checkered", "puzzle", "dice"
        ]
        case .arrows: return [
            "arrow", "chevron", "arrowshape", "triangle",
            "return", "restart", "repeat", "shuffle"
        ]
        case .media: return [
            "play", "pause", "stop", "record", "forward", "backward",
            "speaker", "music", "note", "headphones", "radio",
            "film", "camera", "photo", "video", "waveform",
            "airplay", "pip", "rectangle.on.rectangle", "antenna",
            "tv", "hifispeaker", "appletv"
        ]
        case .editing: return [
            "pencil", "eraser", "paintbrush", "paintpalette", "eyedropper",
            "crop", "ruler", "scissors", "scribble", "highlighter",
            "lasso", "wand", "slider", "dial", "tuningfork",
            "line.diagonal", "selection.pin"
        ]
        case .commerce: return [
            "cart", "bag", "creditcard", "giftcard", "banknote",
            "wallet", "barcode", "qrcode", "storefront", "basket",
            "tag", "purchased", "dollarsign", "eurosign", "yensign",
            "sterlingsign", "indianrupeesign"
        ]
        case .health: return [
            "heart", "cross", "staroflife", "pills", "syringe",
            "bandage", "stethoscope", "medical", "waveform.path",
            "lungs", "allergens", "bolt.heart", "pulse",
            "ivfluid", "microbe"
        ]
        case .objects: return [
            "folder", "doc", "book", "bookmark", "calendar",
            "clock", "alarm", "timer", "stopwatch", "hourglass",
            "lock", "key", "pin", "map", "magnifyingglass",
            "link", "paperclip", "trash", "tray", "archivebox",
            "bin", "cup", "mug", "wineglass", "fork", "lightbulb",
            "lamp", "flashlight", "binoculars", "wrench", "hammer",
            "screwdriver", "briefcase", "suitcase", "backpack",
            "umbrella", "gift", "party"
        ]
        case .shapes: return [
            "circle", "square", "rectangle", "triangle", "diamond",
            "hexagon", "pentagon", "octagon", "oval", "capsule",
            "seal", "star", "shield", "rhombus", "app"
        ]
        }
    }

    static func buildIndex(symbols: [String]) -> [SymbolCategory: Set<String>] {
        var index = [SymbolCategory: Set<String>]()
        for category in SymbolCategory.allCases where category != .all {
            var matched = Set<String>()
            for symbol in symbols {
                for keyword in category.keywords {
                    if symbol.contains(keyword) {
                        matched.insert(symbol)
                        break
                    }
                }
            }
            index[category] = matched
        }
        return index
    }
}
