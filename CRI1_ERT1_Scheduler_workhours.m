%% Index: function code for ERT:CRI Sureying Test Scheduler

function [num_chargers, Testing_Schedule, Testing_Summary] = CRI1_ERT1_Scheduler_workhours(number_of_days, number_of_chargers, number_of_workhours) 
% An automated scheduler using series of linear programming that strictly
% follows the flow of operation and limits the working only up to 8 hours
% per day.
% Limit of runs per 45 mins charge is 10 runs of 1:1(single scenario) or 3:1(Temporal Scenario like liquefaction) - ERT:CRT

%Charging Time Minimization
    num_Rx = optimvar('num_Rx', 'type', 'integer', 'LowerBound',9, 'UpperBound', 9);
    num_chargers = optimvar('num_chargers', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
    charge_iteration = optimvar('charge_iteration', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
    
    prob = optimproblem('Objective', 45*charge_iteration, 'ObjectiveSense','min');
    
    %Constraints%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    prob.Constraints.c1 = num_chargers <= number_of_chargers;
    prob.Constraints.c2 = num_chargers*charge_iteration >= (num_Rx);
    
    [sol, fval] = solve(prob)
    charging_time = fval;
    number_of_chargers = sol.num_chargers

%------------------------------------------------------------------------------------------------------------------------
%Initialization of variables of data compilation
    
    TotalTest_Days = number_of_days;
    TotalNum_Tests = 0;
    Charging = 0;
    time = 0;
    Day = [];
    Sequence_of_Operation = [];
    Number_of_Tests = [];
    Durations = [];
    Total_Duration = [];

%--------------------------------------------------

    for num_day = 1:TotalTest_Days
        while time < 60*number_of_workhours
            if Charging == 0
                %---------------------------------------------
                %ILP with charging
                num_Tests = optimvar('num_Tests', 'type', 'integer', 'LowerBound',0, 'UpperBound', 10);
                charge_time = optimvar('charge_time', 'type', 'integer', 'LowerBound',charging_time, 'UpperBound', charging_time);
                x1 = optimvar('x1', 'type', 'integer', 'LowerBound',0, 'UpperBound', 0);
                x2 = optimvar('x2', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x3 = optimvar('x3', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x4 = optimvar('x4', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x5 = optimvar('x5', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x6 = optimvar('x6', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x7 = optimvar('x7', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                
                d1 = optimvar('d1', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d2 = optimvar('d2', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d3 = optimvar('d3', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d4 = optimvar('d4', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d5 = optimvar('d5', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d6 = optimvar('d6', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d7 = optimvar('d7', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);

                %Objective function
                prob = optimproblem('Objective', charge_time + x7+d7 - 40 + 10, 'ObjectiveSense','max');

                %Constraints%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prob.Constraints.c1 = x2 == x1+d1;
                prob.Constraints.c2 = x3 == x2+d2;
                prob.Constraints.c3 = x4 == x3+d3;
                prob.Constraints.c4 = x5 == x4+d4;
                prob.Constraints.c5 = x6 == x5+d5;
                prob.Constraints.c6 = x7 == x6+d6;
                
                prob.Constraints.c7 = num_Tests <=10;
                prob.Constraints.c8 = charging_time + x7+d7 - 40 + 10 <= 60*number_of_workhours - time;
                
                prob.Constraints.c9 = d1 == 40*num_Tests;
                prob.Constraints.c10 = d2 == 10*num_Tests;
                prob.Constraints.c11 = d3 == 20*num_Tests;
                prob.Constraints.c12 = d4 == 10*num_Tests;
                prob.Constraints.c13 = d5 == 8*num_Tests;
                prob.Constraints.c14 = d6 == 15*num_Tests;
                prob.Constraints.c15 = d7 == 45*num_Tests;

                %Solution
                [sol, fval] = solve(prob)


                time = time+fval;
                hr_min = duration(minutes(fval),'format','hh:mm');
                Charging = duration(minutes(sol.charge_time),'format','hh:mm');
                Test_Duration = duration(minutes(max(fval-sol.charge_time,0)),'format','hh:mm');
                number_of_tests = (sol.x7 + sol.d7)/(40+10+20+10+8+15+45);
                TotalNum_Tests = TotalNum_Tests + number_of_tests;
                Day = [Day; num_day];
                Number_of_Tests = [Number_of_Tests; number_of_tests];
                Sequence_of_Operation = [Sequence_of_Operation; "Charge" "Test Run"];
                Durations = [Durations; Charging Test_Duration];
                Total_Duration = [Total_Duration; sum(Durations(end,:))];
                break
            %-------------------------------------------------------------------------------------------------
            else

                num_Tests = optimvar('num_Tests', 'type', 'integer', 'LowerBound',0, 'UpperBound', 10);
                x1 = optimvar('x1', 'type', 'integer', 'LowerBound',0, 'UpperBound', 0);
                x2 = optimvar('x2', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x3 = optimvar('x3', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x4 = optimvar('x4', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x5 = optimvar('x5', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x6 = optimvar('x6', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                x7 = optimvar('x7', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                
                d1 = optimvar('d1', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d2 = optimvar('d2', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d3 = optimvar('d3', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d4 = optimvar('d4', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d5 = optimvar('d5', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d6 = optimvar('d6', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);
                d7 = optimvar('d7', 'type', 'integer', 'LowerBound',0, 'UpperBound', Inf);

                %Objective funtion
                prob = optimproblem('Objective', x7+d7, 'ObjectiveSense','max');

                %Constraints%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prob.Constraints.c1 = x2 == x1+d1;
                prob.Constraints.c2 = x3 == x2+d2;
                prob.Constraints.c3 = x4 == x3+d3;
                prob.Constraints.c4 = x5 == x4+d4;
                prob.Constraints.c5 = x6 == x5+d5;
                prob.Constraints.c6 = x7 == x6+d6;
                
                prob.Constraints.c7 = num_Tests <=10-TotalNum_Tests;
                prob.Constraints.c8 = x7+d7<= 60*number_of_workhours-time;
                
                prob.Constraints.c9 = d1 == 40*num_Tests;
                prob.Constraints.c10 = d2 == 10*num_Tests;
                prob.Constraints.c11 = d3 == 20*num_Tests;
                prob.Constraints.c12 = d4 == 10*num_Tests;
                prob.Constraints.c13 = d5 == 8*num_Tests;
                prob.Constraints.c14 = d6 == 15*num_Tests;
                prob.Constraints.c15 = d7 == 45*num_Tests;

                %Solution
                [sol, fval] = solve(prob)

                time = time+fval;
                hr_min = duration(minutes(fval),'format','hh:mm');
                Test_Duration = duration(minutes(fval),'format','hh:mm');
                number_of_tests = (sol.x7 + sol.d7)/(40+10+20+10+8+15+45);
                TotalNum_Tests = TotalNum_Tests + number_of_tests;
                
   
                Day = [Day; num_day];
                Number_of_Tests = [Number_of_Tests; number_of_tests];
                Sequence_of_Operation = [Sequence_of_Operation; "Charge" "Test Run"];
                Durations = [Durations; 0 Test_Duration];
                Total_Duration = [Total_Duration; sum(Durations(end,:))];

                if TotalNum_Tests >= 10
                    TotalNum_Tests = 0;
                    Charging = 0;
                end
    
                TotalNum_Tests
                Charging
                time
    
                if (60*number_of_workhours-time) <= (40+10+20+10+8+15) || (60*number_of_workhours-time) <= charging_time
                    break
                end

            end
            


        end
        time = 0
    end

    %Table Generation
    Testing_Schedule = table(Day, Number_of_Tests, Sequence_of_Operation, Durations, Total_Duration);

    Days = [Day(end)];
    Total_Tests = [sum(Testing_Schedule.Number_of_Tests)];
    Charging_Details = [number_of_chargers charging_time];
    Testing_Summary=table(Days, Total_Tests, Charging_Details);        

end