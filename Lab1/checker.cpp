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
    string seg7;
    int seg_en;
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
/*
        4'b0000: out = 8'b11000000; // 0
        4'b0001: out = 8'b11111001; // 1
        4'b0010: out = 8'b10100100; // 2
        4'b0011: out = 8'b10110000; // 3
        4'b0100: out = 8'b10011001; // 4
        4'b0101: out = 8'b10010010; // 5
        4'b0110: out = 8'b10000010; // 6
        4'b0111: out = 8'b11111000; // 7
        4'b1000: out = 8'b10000000; // 8
        4'b1001: out = 8'b10010000; // 9
        4'b1010: out = 8'b10001000; // A
        4'b1011: out = 8'b10000011; // B
        4'b1100: out = 8'b11000110; // C
        4'b1101: out = 8'b10100001; // D
        4'b1110: out = 8'b10000110; // E
        4'b1111: out = 8'b10001110; // F
        default: out = 8'b11111111; // default 0
    endcase
    */
// Function of segment 7 decoder
// 7-segment format: point g f e d c b a
vector<int> seg7(int num) {
    vector<int> seg7_tmp;
    switch (num) {
        case 0:
            seg7_tmp = {1, 1, 0, 0, 0, 0, 0, 0};
            break;
        case 1:
            seg7_tmp = {1, 1, 1, 1, 1, 0, 0, 1};
            break;
        case 2:
            seg7_tmp = {1, 0, 1, 0, 0, 0, 1, 0};
            break;
        case 3:
            seg7_tmp = {1, 0, 1, 1, 0, 0, 0, 0};
            break;
        case 4:
            seg7_tmp = {1, 0, 0, 1, 1, 0, 0, 1};
            break;
        case 5:
            seg7_tmp = {1, 0, 0, 1, 0, 0, 1, 0};
            break;
        case 6:
            seg7_tmp = {1, 0, 0, 0, 0, 0, 1, 0};
            break;
        case 7:
            seg7_tmp = {1, 1, 1, 1, 1, 0, 0, 0};
            break;
        case 8:
            seg7_tmp = {1, 0, 0, 0, 0, 0, 0, 0};
            break;
        case 9:
            seg7_tmp = {1, 0, 0, 1, 0, 0, 0, 0};
            break;
        case 10:
            seg7_tmp = {1, 0, 0, 0, 1, 0, 0, 0};
            break;
        case 11:
            seg7_tmp = {1, 0, 0, 0, 0, 0, 1, 1};
            break;
        case 12:
            seg7_tmp = {1, 1, 0, 0, 0, 1, 1, 0};
            break;
        case 13:
            seg7_tmp = {1, 1, 0, 1, 0, 0, 1, 0};
            break;
        case 14:
            seg7_tmp = {1, 0, 0, 0, 0, 1, 1, 0};
            break;
        case 15:
            seg7_tmp = {1, 0, 0, 1, 0, 1, 1, 0};
            break;
        default:
            seg7_tmp = {1, 1, 1, 1, 1, 1, 1, 1};
            break;
    }
    return seg7_tmp;
}

vector<int> seg7_en(int en) {
    vector<int> seg7_en_tmp;
    if (en == 1) {
        seg7_en_tmp = {1, 1, 1, 1, 1, 1, 1, 0};
    } else {
        seg7_en_tmp = {1, 1, 1, 1, 1, 1, 1, 1};
    }
    return seg7_en_tmp;
}

// Function to convert X and Y to 7-segment format
vector<int> seg7(int X, int Y) {
    vector<int> seg7_tmp;
    X = X + 2;
    Y = 2 * Y;
    
    seg7_tmp.insert(seg7_tmp.end(), seg7(Y).end(), seg7(Y).begin()); // Add Y [15:8]
    seg7_tmp.insert(seg7_tmp.end(), seg7(X).end(), seg7(X).begin()); // Add X [7:0]

    return seg7_tmp;
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
        string time_str, X_str, Y_str, sel, out_bin, out_dec_str, seg7_str, seg_en_str; // Output format: time, X, Y, sel, out, seg7, seg_en
        
        // Read values separated by commas
        getline(iss, time_str, ',');
        getline(iss, X_str, ',');
        getline(iss, Y_str, ',');
        getline(iss, sel, ',');
        getline(iss, out_bin, ',');
        getline(iss, out_dec_str, ','); // ?
        getline(iss, seg7_str, ',');
        getline(iss, seg_en_str, ',');

        // Convert values
        int time = stoi(time_str);
        int X = stoi(X_str, nullptr, 2); // Convert binary string to int
        int Y = stoi(Y_str, nullptr, 2); // Convert binary string to int
        int out_dec = stoi(out_dec_str);
        int seg_en = stoi(seg_en_str);

        // Store parsed data
        data.push_back({time, X, Y, sel, out_bin, out_dec, seg7_str, seg_en});
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
