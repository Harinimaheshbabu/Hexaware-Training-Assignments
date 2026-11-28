
package utilitybilling;

import java.util.Scanner;

public class UtilityBilling {

    // Method to calculate electricity charges using four slabs
    public static double calculateSlabCharge(int units) {

        double amount = 0;

        if (units <= 100) {
            amount = units * 1.50;
        } 
        else if (units <= 200) {
            amount = (100 * 1.50) + (units - 100) * 2.50;
        } 
        else if (units <= 400) {
            amount = (100 * 1.50) + (100 * 2.50)
                    + (units - 200) * 4.00;
        } 
        else {
            amount = (100 * 1.50) + (100 * 2.50)
                    + (200 * 4.00) + (units - 400) * 6.00;
        }

        return amount;
    }

    // Method to get fixed charge based on consumer category
    public static double getFixedCharge(String category) {

        return switch (category.toLowerCase()) {
            case "domestic" -> 50.0;
            case "commercial" -> 150.0;
            case "industrial" -> 300.0;
            default -> -1.0;
        };
    }

    // Method to calculate final bill
    public static double calculateBill(int units, String category,
                                       boolean latePayment,
                                       boolean onlinePayment) {

        double energyCharge = calculateSlabCharge(units);
        double fixedCharge = getFixedCharge(category);

        if (fixedCharge == -1) {
            return -1;
        }

        double total = energyCharge + fixedCharge;

        // Operator precedence: multiplication (*) is evaluated before
        // addition (+), so surcharge is calculated on the energy charge.
        if (latePayment) {
            total = total + energyCharge * 0.05;
        }

        if (onlinePayment) {
            total = total - total * 0.02;
        }

        return total;
    }

    // Demonstrating primitive type casting
    public static void demonstrateCasting() {

        System.out.println("\n--- Primitive Casting Examples ---");

        int a = 10;
        int b = 3;

        // Integer division removes the decimal part
        System.out.println("Integer division: " + (a / b));

        // Correct handling using double
        double result = (double) a / b;
        System.out.printf("Correct division: %.2f%n", result);

        // Integer overflow example
        int maxValue = Integer.MAX_VALUE;
        System.out.println("Integer overflow: " + (maxValue + 1));

        // Correct handling using long
        long correctValue = (long) maxValue + 1;
        System.out.println("Using long: " + correctValue);

        // Double to int conversion removes decimal part
        double price = 249.85;
        int convertedPrice = (int) price;
        System.out.println("Double to int: " + convertedPrice);

        // Correct handling when rounding is required
        int roundedPrice = (int) Math.round(price);
        System.out.println("Rounded price: " + roundedPrice);
    }

    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);

        var category = "domestic";

        System.out.println("===== UTILITY BILLING CALCULATOR =====");

        System.out.print("Enter consumer name: ");
        String name = sc.nextLine();

        System.out.print("Enter consumer category (domestic/commercial/industrial): ");
        category = sc.nextLine();

        System.out.print("Enter electricity units consumed: ");
        int units = sc.nextInt();

        if (units < 0) {
            System.out.println("Invalid units. Consumption cannot be negative.");
            sc.close();
            return;
        }

        System.out.print("Is the payment late? (true/false): ");
        boolean latePayment = sc.nextBoolean();

        System.out.print("Is payment made online? (true/false): ");
        boolean onlinePayment = sc.nextBoolean();

        double bill = calculateBill(units, category, latePayment, onlinePayment);

        if (bill == -1) {
            System.out.println("Invalid consumer category.");
        } else {
            System.out.println("\n========== BILL DETAILS ==========");
            System.out.println("Consumer Name : " + name);
            System.out.println("Category      : " + category);
            System.out.println("Units Used    : " + units);
            System.out.printf("Final Bill    : Rs. %.2f%n", bill);
        }

        // Producing a 12-month electricity statement using for loop
        System.out.println("\n========== 12 MONTH STATEMENT ==========");

        for (int month = 1; month <= 12; month++) {
            System.out.printf("Month %2d : Rs. %.2f%n", month, bill);
        }

        // Reading meter readings until the user enters 0
        System.out.println("\n========== METER READING ENTRY ==========");

        int reading;

        do {
            System.out.print("Enter meter reading (0 to stop): ");
            reading = sc.nextInt();

            if (reading > 0) {
                System.out.println("Meter reading recorded: " + reading);
            } else if (reading < 0) {
                System.out.println("Invalid reading. Enter a positive value.");
            }

        } while (reading != 0);

        // Displaying primitive casting examples
        demonstrateCasting();

        sc.close();
    }
}
