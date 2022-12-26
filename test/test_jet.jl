using QuantumSymbolics, QSymbolicsBase, QSymbolicsOptics, JET

using JET: ReportPass, BasicPass, InferenceErrorReport, UncaughtExceptionReport

# Custom report pass that ignores `UncaughtExceptionReport`
# Too coarse currently, but it serves to ignore the various
# "may throw" messages for runtime errors we raise on purpose
# (mostly on malformed user input)
struct MayThrowIsOk <: ReportPass end

# ignores `UncaughtExceptionReport` analyzed by `JETAnalyzer`
(::MayThrowIsOk)(::Type{UncaughtExceptionReport}, @nospecialize(_...)) = return

# forward to `BasicPass` for everything else
function (::MayThrowIsOk)(report_type::Type{<:InferenceErrorReport}, @nospecialize(args...))
    BasicPass()(report_type, args...)
end

rep_base = report_package("QSymbolicsBase";
    report_pass=MayThrowIsOk(), # TODO have something more fine grained than a generic "do not care about thrown errors"
)
@show rep_base
@test_broken length(JET.get_reports(rep_base)) == 0

rep_opt = report_package("QSymbolicsOptics";
    report_pass=MayThrowIsOk(), # TODO have something more fine grained than a generic "do not care about thrown errors"
)
@show rep_opt
@test_broken length(JET.get_reports(rep_opt)) == 0

rep_cliff = report_package("QSymbolicsClifford";
    report_pass=MayThrowIsOk(), # TODO have something more fine grained than a generic "do not care about thrown errors"
)
@show rep_cliff
@test_broken length(JET.get_reports(rep_cliff)) == 0

rep = report_package("QuantumSymbolics";
    report_pass=MayThrowIsOk(), # TODO have something more fine grained than a generic "do not care about thrown errors"
)
@show rep
@test length(JET.get_reports(rep)) == 0
