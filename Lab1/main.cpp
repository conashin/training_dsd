#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <iomanip> // Required for setw()
#include <bitset>

using namespace std;

// Structure to store simulation data
struct SimulationData {
    int time;
    int X, Y;
    string sel;
    string out_bin;
    int out_dec;
};

// Function for sel=00 (8X + Y)
int sel_00(int X, int Y) {
    return (8 * X) + Y;
}

// Function for sel=01 (16 * Y + X)
int sel_01(int X, int Y) {
    return (16 * Y) + X;
}

// Function for sel=10 (X << Y) (shift left) -- FIXED!
int sel_10(int X, int Y) {
    return (X << Y) & 0xFF; // 保留低 8-bit，模擬 Verilog
}

// Function for sel=11 (Y >> X) (shift right)
int sel_11(int X, int Y) {
    return Y >> X;
}

int main() {
    ifstream file("Lab1_output.txt"); // Open the txt file
    if (!file) {
        cerr << "Error: Unable to open file!" << endl;
        return 1;
    }

    vector<SimulationData> data; // Store parsed data
    string line;

    // Skip the header line
    getline(file, line);

    // Read the file line by line
    while (getline(file, line)) {
        istringstream iss(line);
        string time_str, X_str, Y_str, sel, out_bin, out_dec_str;
        
        // Read values separated by commas
        getline(iss, time_str, ',');
        getline(iss, X_str, ',');
        getline(iss, Y_str, ',');
        getline(iss, sel, ',');
        getline(iss, out_bin, ',');
        getline(iss, out_dec_str, ',');

        // Convert values
        int time = stoi(time_str);
        int X = stoi(X_str, nullptr, 2); // Convert binary string to int
        int Y = stoi(Y_str, nullptr, 2); // Convert binary string to int
        int out_dec = stoi(out_dec_str);

        // Store parsed data
        data.push_back({time, X, Y, sel, out_bin, out_dec});
    }

    file.close();

    // Display the parsed results with proper alignment
    cout << "Parsed Data with Validation:" << endl;
    cout << "-----------------------------------------------------------------------------" << endl;
    cout << setw(10) << "Time" 
         << setw(8) << "X" 
         << setw(8) << "Y" 
         << setw(8) << "sel" 
         << setw(15) << "out_bin" 
         << setw(8) << "out_dec" 
         << setw(10) << "Expected" 
         << setw(8) << "Status" << endl;
    cout << "-----------------------------------------------------------------------------" << endl;
    bool is_sat=true;
    for (const auto& entry : data) {
        int expected_output = 0;

        // Compute expected output based on sel value
        if (entry.sel == "00") {
            expected_output = sel_00(entry.X, entry.Y);
        } else if (entry.sel == "01") {
            expected_output = sel_01(entry.X, entry.Y);
        } else if (entry.sel == "10") {
            expected_output = sel_10(entry.X, entry.Y); // Now correctly simulating Verilog
        } else if (entry.sel == "11") {
            expected_output = sel_11(entry.X, entry.Y);
        }

        // Check if the expected output matches the actual out_dec
        bool match = (expected_output == entry.out_dec);
        if(!match) is_sat=false;
        string status = match ? "PASS" : "FAIL";

        cout << setw(10) << entry.time
             << setw(8) << bitset<3>(entry.X)  // Print X as a 3-bit binary
             << setw(8) << bitset<3>(entry.Y)  // Print Y as a 3-bit binary
             << setw(8) << entry.sel
             << setw(15) << entry.out_bin
             << setw(8) << entry.out_dec
             << setw(10) << expected_output
             << setw(8) << status << endl;
    }

    cout << "-----------------------------------------------------------------------------" << endl;

    if(is_sat)
    cout<<"Correct!"<<endl;
    else
    cout<<"Fail!"<<endl;

    return 0;
}
