export interface FareQuote {
  unitPrice: number;
  passengerCount: number;
  totalPrice: number;
  currency: 'IDR';
}

export class FareService {
  static quote(connectionCount: number, passengerCount = 1): FareQuote {
    if (!Number.isInteger(connectionCount) || connectionCount < 1) {
      throw new Error('A fare requires at least one connection');
    }
    if (!Number.isInteger(passengerCount) || passengerCount < 1 || passengerCount > 6) {
      throw new Error('Passenger count must be between 1 and 6');
    }

    // Product estimate until an official operator fare API is connected.
    const distanceBands = Math.ceil(Math.max(0, connectionCount - 5) / 5);
    const unitPrice = 3000 + distanceBands * 1000;
    return {
      unitPrice,
      passengerCount,
      totalPrice: unitPrice * passengerCount,
      currency: 'IDR',
    };
  }
}
