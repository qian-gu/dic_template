// DESCRIPTION: Verilator template sim_main wrapper
//
// Modified from verilator/example/make_trace_c/sim_main.cpp
//======================================================================

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "blinky.v"
#include "Vtb_top.h"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

int main(int argc, char** argv, char** env) {

    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "tb_top.v".
    // Using unique_ptr is similar to "Vtop* tb_top = new Vtb_top" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vtb_top> tb_top{new Vtb_top{contextp.get(), "TOP"}};

    // Set Vtb_top's input signals
    tb_top->rst_ni = !0;
    tb_top->clk_i = 0;
    tb_top->en_i = 1;

    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions just assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(1);  // 1 timeprecision period passes...
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        tb_top->clk_i = !tb_top->clk_i;

        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk_i, because we know
        // reset is not sampled there.
        if (!tb_top->clk_i) {
            if (contextp->time() > 1 && contextp->time() < 10) {
                tb_top->rst_ni = !1;  // Assert reset
            } else {
                tb_top->rst_ni = !0;  // Deassert reset
            }
            // Assign some other inputs
            tb_top->en_i = 1;
        }

        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        tb_top->eval();

        // Read outputs
        // VL_PRINTF("[%" PRId64 "] clk_i=%x rst_ni=%x en_i=%" PRIx64 " -> oquad=%" PRIx64
        //           " owide=%x_%08x_%08x\n",
        //           contextp->time(), tb_top->clk_i, tb_top->rst_ni, tb_top->in_quad, tb_top->out_quad,
        //           tb_top->out_wide[2], tb_top->out_wide[1], tb_top->out_wide[0]);
    }

    // Final model cleanup
    tb_top->final();

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}
