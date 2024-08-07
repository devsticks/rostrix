[![macos](https://github.com/devsticks/rostrix/actions/workflows/macos.yml/badge.svg)](https://github.com/devsticks/rostrix/actions/workflows/macos.yml) [![tests](https://github.com/devsticks/rostrix/actions/workflows/tests.yml/badge.svg)](https://github.com/devsticks/rostrix/actions/workflows/tests.yml) [![codecov](https://codecov.io/github/devsticks/rostrix/graph/badge.svg?token=KTXO3HV7SL)](https://codecov.io/github/devsticks/rostrix)
# Rostrix

An automated doctors' roster builder, written in Flutter. For now, set up with the rules followed by Settlers Hospital in Makhanda, South Africa.
Settlers is a district hospital with 10 Medical Officers.

## Rules:
1. All calls require that someone who is competent to cut caesarian sections and someone competent in anaesthetics be available.
2. Weekday calls have three roles:
   1. A main doctor (who works 4pm to 8am), 
   2. A second-on-call doctor (who works 4pm to 10pm), and 
   3. A caesar cover doctor (who works from 4pm to 8am, and will be called out if a caesar needs to be performed).
3. Weekend and public holiday calls have four roles:
   1. Two day doctors (who work from 8am to 8pm),
   2. A night doctor (who works from 8pm to 8am),
   3. A caesar cover doctor (who works from 8pm to 8am, and will be called out if necessary)
4. Unless for a weekend, a doctor should never work two shifts in a row
5. A doctor should not be rostered if they are on leave, and the weekends either side of a leave block - along with the preceding Friday - should be treated as part of the leave block.

## Aims:
1. Where possible, the roster should be set up to utilise as few doctors as possible per shift - for instance, on a weeknight if the role of caesar cover can also be performed by the second on call (the doctor working the 4-10pm slot), this is preferred - though this depends on the skillsets of this doctor and the main doctor being complementary. For weekend and public holiday shifts this means using one of the day doctors as the night caesar cover doctor.
2. Usually, the Saturday and Sunday roles should be duplicated.
3. The time between successive calls should be maximised so that they are as spread out as possible.