using System;
using System.Threading;

// Enum state FSM
public enum FsmState
{
    S0_INIT   = 0,
    S1_NORMAL = 1,
    S2_WARN   = 2,
    S3_FAULT  = 3,
    S4_EMG    = 4
}

public class SensorActuatorFsm
{
    public FsmState State { get; private set; } = FsmState.S0_INIT;

    // Step = 1 siklus clock
    public void Step(
        bool reset,
        bool allSensOk,
        bool warnSensor,
        bool faultAct,
        bool emg)
    {
        FsmState next = State;

        // prioritas paling tinggi
        if (reset)
        {
            next = FsmState.S0_INIT;
        }
        else if (emg)
        {
            next = FsmState.S4_EMG;
        }
        else
        {
            switch (State)
            {
                case FsmState.S0_INIT:
                    // INIT -> NORMAL kalau semua sensor OK
                    if (allSensOk)
                        next = FsmState.S1_NORMAL;
                    // kalau belum OK, tetap INIT
                    break;

                case FsmState.S1_NORMAL:
                    if (faultAct)
                        next = FsmState.S3_FAULT;
                    else if (warnSensor)
                        next = FsmState.S2_WARN;
                    // else tetap NORMAL
                    break;

                case FsmState.S2_WARN:
                    if (faultAct)
                        next = FsmState.S3_FAULT;
                    else if (allSensOk)
                        next = FsmState.S1_NORMAL;
                    // else tetap WARN
                    break;

                case FsmState.S3_FAULT:
                    // balik NORMAL hanya jika fault hilang dan sensor OK
                    if (!faultAct && allSensOk)
                        next = FsmState.S1_NORMAL;
                    // else tetap FAULT
                    break;

                case FsmState.S4_EMG:
                    // EMG hanya keluar via reset
                    break;

                default:
                    next = FsmState.S0_INIT;
                    break;
            }
        }

        State = next; // setara perilaku D flip-flop
    }
}

public class Program
{
    // Contoh “sensor” untuk simulasi di dotnetfiddle
    static int t = 0;

    public static void Main()
    {
        var fsm = new SensorActuatorFsm();

        Console.WriteLine("=== FSM Simulation Start ===");

        // simulasi 12 siklus clock
        for (t = 0; t < 12; t++)
        {
            // baca input sensor (di sini disimulasikan)
            bool reset      = ReadResetButton();
            bool allSensOk  = ReadAllSensorsOk();
            bool warnSensor = ReadWarning();
            bool faultAct   = ReadActuatorFault();
            bool emg        = ReadEmergencySignal();

            // update FSM
            fsm.Step(reset, allSensOk, warnSensor, faultAct, emg);

            // kontrol aktuator (simulasi)
            ControlActuatorsBasedOnState(fsm.State);

            // tampilkan status
            Console.WriteLine(
                $"t={t:00} | reset={reset} ok={allSensOk} warn={warnSensor} fault={faultAct} emg={emg} -> state={fsm.State}"
            );

            Thread.Sleep(200); // biar kebaca pelan (boleh dihapus)
        }

        Console.WriteLine("=== FSM Simulation End ===");
    }

    // ==== STUB INPUTS (gantikan dengan fungsi mikrokontrolermu) ====
    static bool ReadResetButton()
    {
        // reset hanya di awal simulasi
        return t == 0;
    }

    static bool ReadAllSensorsOk()
    {
        // normal setelah t>=1, kecuali saat warning/fault/emg
        if (ReadEmergencySignal()) return false;
        if (ReadActuatorFault()) return false;
        if (ReadWarning()) return false;
        return t >= 1;
    }

    static bool ReadWarning()
    {
        // warning aktif di t=3..4
        return (t >= 3 && t <= 4);
    }

    static bool ReadActuatorFault()
    {
        // fault aktif di t=6..7
        return (t >= 6 && t <= 7);
    }

    static bool ReadEmergencySignal()
    {
        // emg aktif di t=9..10
        return (t >= 9 && t <= 10);
    }

    // ==== STUB OUTPUTS ====
    static void ControlActuatorsBasedOnState(FsmState s)
    {
        // contoh mapping sederhana (silakan sesuaikan)
        switch (s)
        {
            case FsmState.S0_INIT:
                // shutter close + relay isolate
                break;
            case FsmState.S1_NORMAL:
                // all actuators normal
                break;
            case FsmState.S2_WARN:
                // fan on, maybe limit gantry
                break;
            case FsmState.S3_FAULT:
                // shutdown imaging, isolate
                break;
            case FsmState.S4_EMG:
                // full stop emergency
                break;
        }
    }
}
