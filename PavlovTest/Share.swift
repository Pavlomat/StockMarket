//
//  Share.swift
//  PavlovTest
//
//  Created by Pavlov Matthew on 16.02.2021.
//

import Foundation

//создаю структуру для данных с апи
struct Share: Codable, Equatable, Hashable {
    
    let ask: Double?
    let askSize: Int?
    let averageDailyVolume10Day, averageDailyVolume3Month: Int
    let bid: Double?
    let bidSize: Int?
    let bookValue: Double?
    let currency: String?
    let dividendDate, earningsTimestamp, earningsTimestampStart, earningsTimestampEnd: RegularMarketTime?
    let epsForward, epsTrailingTwelveMonths: Double?
    let exchange: String
    let exchangeDataDelayedBy: Int
    let exchangeTimezoneName, exchangeTimezoneShortName: String
    let fiftyDayAverage: Double
    let fiftyDayAverageChange, fiftyDayAverageChangePercent: Double?
    let fiftyTwoWeekHigh: Double
    let fiftyTwoWeekHighChange, fiftyTwoWeekHighChangePercent: Double?
    let fiftyTwoWeekLow: Double
    let fiftyTwoWeekLowChange, fiftyTwoWeekLowChangePercent: Double?
    let financialCurrency: String?
    let forwardPE: Double?
    let fullExchangeName: String
    let gmtOffSetMilliseconds: Int
    let language: String
    let longName: String?
    let market: String
    let marketCap: Int?
    let marketState: String
    let messageBoardID: String?
    let postMarketChange, postMarketChangePercent, postMarketPrice, postMarketTime: JSONNull?
    let priceHint: Int
    let priceToBook: Double?
    let quoteSourceName, quoteType: String
    let regularMarketChange, regularMarketChangePercent, regularMarketDayHigh, regularMarketDayLow: Double?
    let regularMarketOpen, regularMarketPreviousClose, regularMarketPrice: Double?
    let regularMarketTime: RegularMarketTime
    let regularMarketVolume, sharesOutstanding: Int?
    let shortName: String?
    let sourceInterval: Int
    let symbol: String
    let tradeable: Bool
    let trailingAnnualDividendRate, trailingAnnualDividendYield, trailingPE: Double?
    let twoHundredDayAverage: Double
    let twoHundredDayAverageChange, twoHundredDayAverageChangePercent: Double?

    enum CodingKeys: String, CodingKey {
        case ask, askSize, averageDailyVolume10Day, averageDailyVolume3Month, bid, bidSize, bookValue, currency, dividendDate, earningsTimestamp, earningsTimestampStart, earningsTimestampEnd, epsForward, epsTrailingTwelveMonths, exchange, exchangeDataDelayedBy, exchangeTimezoneName, exchangeTimezoneShortName, fiftyDayAverage, fiftyDayAverageChange, fiftyDayAverageChangePercent, fiftyTwoWeekHigh, fiftyTwoWeekHighChange, fiftyTwoWeekHighChangePercent, fiftyTwoWeekLow, fiftyTwoWeekLowChange, fiftyTwoWeekLowChangePercent, financialCurrency, forwardPE, fullExchangeName, gmtOffSetMilliseconds, language, longName, market, marketCap, marketState
        case messageBoardID = "messageBoardId"
        case postMarketChange, postMarketChangePercent, postMarketPrice, postMarketTime, priceHint, priceToBook, quoteSourceName, quoteType, regularMarketChange, regularMarketChangePercent, regularMarketDayHigh, regularMarketDayLow, regularMarketOpen, regularMarketPreviousClose, regularMarketPrice, regularMarketTime, regularMarketVolume, sharesOutstanding, shortName, sourceInterval, symbol, tradeable, trailingAnnualDividendRate, trailingAnnualDividendYield, trailingPE, twoHundredDayAverage, twoHundredDayAverageChange, twoHundredDayAverageChangePercent
    }
}

// MARK: - RegularMarketTime
struct RegularMarketTime: Codable, Equatable, Hashable {
    let date: String
    let timezoneType: Int
    let timezone: Timezone

    enum CodingKeys: String, CodingKey, Equatable {
        case date
        case timezoneType = "timezone_type"
        case timezone
    }
}

enum Timezone: String, Codable, Equatable, Hashable {
    case the0000 = "+00:00"
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable, Equatable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
