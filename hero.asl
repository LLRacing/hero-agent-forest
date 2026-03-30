//STUDENT NAME: Sheung Bun Larry Lee
//STUDENT ID: 201952256

//Hero is at the position of agent P (variable), if agent P's position is identical to Hero's position 
at(P) :- pos(P,X,Y) & pos(hero,X,Y).

//Initial goal
!started.

/*
* In the event that the agent must achieve "started", under all circumstances, print the message.
*/
+!started 
   :true
   <- .print("I'm not scared of that smelly Goblin!");
      !checkItem.

// Advance scan when hero is missing items, current slot has no item, and hero is not at (7,7).
+!checkItem 
   : not (hero(coin) & hero(gem) & hero(vase)) &            // Return TRUE if hero does not have all three items.
   not coin(hero) &                                         // Return TRUE if there is no coin on the current slot.
   not gem(hero) &                                          // Return TRUE if there is no gem on the current slot.
   not vase(hero) &                                         // Return TRUE if there is no vase on the current slot.
   not pos(hero,7,7)                                        // Return TRUE if hero is not at the last slot on the grid.
   <- !advance_scan;                                        // Post goal !advance_scan (scan step with teleport recovery).
      !checkItem.                                           // Loop !checkItem again since hero is moved to the next slot.

+!advance_scan                                                // Plan: perform one scan step and detect teleport.
   <- ?pos(hero,OldX,OldY);                                   // Query hero current position before next(slot).
      !next_of(OldX,OldY,ExpectedX,ExpectedY);                // Compute expected next slot if no teleport occurs.
      next(slot);                                             // Environment action: move to next scan slot.
      ?pos(hero,NewX,NewY);                                   // Query hero actual position after next(slot).
      !recover_if_teleported(ExpectedX,ExpectedY,NewX,NewY).  // Compare expected vs actual to detect teleport.

+!next_of(OldX,OldY,ExpectedX,ExpectedY) 
   : OldX < 7 		                                          // TRUE if hero is not at last column.
   <- ExpectedX = OldX + 1;                                 // Next X is one step right.
      ExpectedY = OldY.                                     // Next Y stays same row.

+!next_of(OldX,OldY,ExpectedX,ExpectedY)                    // Context: at last column, not bottom row.
   : OldX == 7 & OldY < 7                                   // TRUE if hero is at last colume of the frid, but not last row of the grid.
   <- ExpectedX = 0;                                        // Wrap to first column.
      ExpectedY = OldY + 1.                                 // Move down to next row.

+!recover_if_teleported(ExpectedX,ExpectedY,ExpectedX,ExpectedY). // Safety case: expected == actual, no teleport.

// Matching plan to pick up the coin when hero does not have coin already.
+!checkItem 
   : coin(hero) & not hero(coin)                            // Context holds when hero is on a coin slot and does not already hold coin.
   <- pick(coin);                                           // Call the action to pick up the coin.
      .print("I've got a coin");                            // Internal action: Output message to the console.
      !checkItem.                                           // Re-post !checkItem to continue the control loop. 

// Matching plan to pick up the gem when hero does not have gem already.
+!checkItem 
   : gem(hero) & not hero(gem)                              // Context holds when hero is on a gem slot and does not already hold gem.
   <- pick(gem);                                            // Call the action to pick up the gem.
      .print("I've got a gem");                             // Internal action: Output message to the console.
      !checkItem.                                           // Re-post !checkItem to continue the control loop.  

// Matching plan to pick up the vase when hero does not have vase already.
+!checkItem 
   : vase(hero) & not hero(vase)                            // Context holds when hero is on a vase slot and does not already hold vase.
   <- pick(vase);                                           // Call the action to pick up the vase.
      .print("I've got a vase");                            // Internal action: Output message to the console.
      !checkItem.                                           // Re-post !checkItem to continue the control loop.  

// If hero holds coin, gem, and vase, post goal !toGoblin.
+!checkItem 
   : hero(coin) & hero(gem) & hero(vase)                    // TRUE if the hero has all the three items.
   <- !toGoblin.                                            // Post achievement goal !toGoblin.

// Loop of move hero to the goblin.
+!at(goblin) 
   : not at(goblin)                                         // TRUE if hero not at the Goblin's location.
   <- ?pos(goblin,X,Y);                                     // Check Goblin's position from the belief base.
      move_towards(X,Y);                                    // Move hero to the Goblin's position by one slot.
      !at(goblin).                                          // Re-post the goal to re-check at(goblin) and continue moving until it becomes true.

+!at(goblin)
   : at(goblin)                                             // Already at goblin → goal satisfied.
   <- true.                                                 // Success with no further actions.

// Matching plan to drop all items to Goblin.
+!toGoblin 
   <- !at(goblin);
         .print("Here is your coin!");                      // Internal action: Output message to the console.
         drop(coin);                                        // Call the action to drop the coin to Goblin.
         .print("Here is your gem!");                       // Internal action: Output message to the console.
         drop(gem);                                         // Call the action to drop the gem to Goblin.
         .print("Here is your vase!");                      // Internal action: Output message to the console.
         drop(vase).                                        // Call the action to drop the vase to Goblin.


// Safety-net plan for goal !toGoblin.
+!toGoblin
   : not (hero(coin) & hero(gem) & hero(vase))
   <- .print("Not going to goblin: missing item(s).").

// ********************** Below are additional code for preset 1 - Not all items present *************************** //

// Report collected and missing items when hero reaches end of scan at (7,7) without all required items.
+!checkItem 
   : not (hero(coin) & hero(gem) & hero(vase)) &            // True if hero does not hold all three required items.
      pos(hero,7,7) &                                       // TRUE if hero is at the last slot on the grid.
                                                            // The next three checks ensure no still-needed item is left on the current slot.
      (hero(coin) | not coin(hero)) &                       // TRUE if hero has a coin OR there is no coin on the current slot.
      (hero(gem)  | not gem(hero))  &                       // TRUE if hero has a gem OR there is no gem on the current slot.
      (hero(vase) | not vase(hero))                         // TRUE if hero has a vase OR there is no vase on the current slot.
   <- .print("Something is missing");                       // Internal action: Output message to the console.
      !report_item(coin);                                   // Post achievement goal !report_item(coin).
      !report_item(gem);                                    // Post achievement goal !report_item(gem).
      !report_item(vase).                                   // Post achievement goal !report_item(vase).

// Report whether hero currently holds the requested item.
+!report_item(Item) 
   : hero(Item)                                             // TRUE when hero holds Item.
   <- .print("I have got: ", Item).                         // Internal action: Output message to the console.

// Report when hero does not hold the requested item.
+!report_item(Item) 
   : not hero(Item)                                         // TRUE when hero does not hold Item.
   <- .print("This is missing: ", Item).                    // Internal action: Output message to the console.

// Safety net for plan !report_item.
+!report_item(_).

// ********************** Below are additional code for preset 3 - Some duplicate items present *************************** //

// Matching plan to move on when hero's current slot has a coin, but hero already has a coin.
+!checkItem 
   : coin(hero) &                                           // Check if hero's current slot has coin.
      hero(coin) &                                          // Check if hero already has a coin.
      not pos(hero,7,7)                                     // Check if hero not on the last slot of the grid.
   <- .print("I've got a coin already!");                   // Internal action: Output message to the console.
      !advance_scan;                                        // Post goal !advance_scan (scan step with teleport recovery).
      !checkItem.                                           // Create an achievement goal (event) to check if there is any item on the current slot.

// Matching plan to move on when hero's current slot has a gem, but hero already has a gem.
+!checkItem 
   : gem(hero) &                                            // Check if hero's current slot has gem.
      hero(gem) &                                           // Check if hero already has a gem.
      not pos(hero,7,7)                                     // Check if hero not on the last slot of the grid.
   <- .print("I've got a gem already!");                    // Internal action: Output message to the console.
      !advance_scan;                                        // Post goal !advance_scan (scan step with teleport recovery).
      !checkItem.                                           // Create an achievement goal (event) to check if there is any item on the current slot.

// Matching plan to move on when hero's current slot has a vase, but hero already has a vase.
+!checkItem 
   : vase(hero) &                                           // Check if hero's current slot has vase.
      hero(vase) &                                          // Check if hero already has a vase.
      not pos(hero,7,7)                                     // Check if hero not on the last slot of the grid.
   <- .print("I've got a vase already!");                    // Internal action: Output message to the console.
      !advance_scan;                                        // Post goal !advance_scan (scan step with teleport recovery).
      !checkItem.                                           // Create an achievement goal (event) to check if there is any item on the current slot.

// Safety-net plan for goal !checkItem.
+!checkItem.

// ********************** Below are additional code for preset 4 - A teleporter is present *************************** //

// Teleport at final scan slot: expected (7,7) but actual position differs.
+!recover_if_teleported(7,7,NewX,NewY)
   : 7 \== NewX | 7 \== NewY                               // TRUE if expected next slot of hero is the last slot on grid, but acutal coordinate is not.
   <- .print("Teleport detected at final slot.");          // Debug output.
      .print("Something is missing");                      // Report incomplete collection.
      !report_item(coin);                                  // Report coin status.
      !report_item(gem);                                   // Report gem status.
      !report_item(vase).                                  // Report vase status.

// Teleport detected and move to one slot next to teleporter.
+!recover_if_teleported(ExpectedX,ExpectedY,NewX,NewY)      // Teleport recovery plan.
   : (ExpectedX \== NewX | ExpectedY \== NewY) &            // TRUE if either X or Y differs from expected.
      not (ExpectedX == 7 & ExpectedY == 7)                 // Exclude final-slot case so generic recovery never calls next_of(7,7,...).
   <- .print("Teleport detected.");     					      // Internal action: print debug message.
      !next_of(ExpectedX,ExpectedY,ResumeX,ResumeY);        // Compute resume slot (one slot after teleporter slot).
      !goTo_avoid(ResumeX,ResumeY,ExpectedX,ExpectedY).     // Move to resume slot while avoiding teleporter coordinate.



// Recursive case: still moving to resume target while avoiding teleporter coordinate.
+!goTo_avoid(ResumeX,ResumeY,TeleportX,TeleportY)
   : not pos(hero,ResumeX,ResumeY)                          // TRUE if hero is not at the resume coordinate.
   <- !predict_step(ResumeX,ResumeY,PredictedX,PredictedY); // Predict next move_towards step.
      !step_or_detour(ResumeX,ResumeY,TeleportX,TeleportY,PredictedX,PredictedY); // Choose normal step or detour.
      !goTo_avoid(ResumeX,ResumeY,TeleportX,TeleportY).      // Continue until target reached.

// Safety stop: resume target already reached, so stop goTo_avoid recursion.
+!goTo_avoid(ResumeX,ResumeY,TeleportX,TeleportY)
   : pos(hero,ResumeX,ResumeY).

// Unification case: selected only when predicted step equals blocked teleporter slot.
+!step_or_detour(ResumeX,ResumeY,TeleportX,TeleportY,TeleportX,TeleportY)
   <- !detour_one(TeleportX,TeleportY).                    // Take one detour move.

// Selected when predicted step is not the blocked teleporter slot.
+!step_or_detour(ResumeX,ResumeY,TeleportX,TeleportY,PredictedX,PredictedY)
   : PredictedX \== TeleportX | PredictedY \== TeleportY
   <- move_towards(ResumeX,ResumeY).                       // Move normally toward resume target.

// Detour preference 1: move down if inside grid and not stepping onto teleporter.
+!detour_one(TeleportX,TeleportY)
   : pos(hero,CurrentX,CurrentY) & CurrentY < 7 & not (CurrentX == TeleportX & CurrentY+1 == TeleportY)
   <- move_towards(CurrentX,CurrentY+1).

// Detour preference 2: move up if safe.
+!detour_one(TeleportX,TeleportY)
   : pos(hero,CurrentX,CurrentY) & CurrentY > 0 & not (CurrentX == TeleportX & CurrentY-1 == TeleportY)
   <- move_towards(CurrentX,CurrentY-1).

// Detour preference 3: move right if safe.
+!detour_one(TeleportX,TeleportY)
   : pos(hero,CurrentX,CurrentY) & CurrentX < 7 & not (CurrentX+1 == TeleportX & CurrentY == TeleportY)
   <- move_towards(CurrentX+1,CurrentY).

// Detour preference 4: move left if safe.
+!detour_one(TeleportX,TeleportY)
   : pos(hero,CurrentX,CurrentY) & CurrentX > 0 & not (CurrentX-1 == TeleportX & CurrentY == TeleportY)
   <- move_towards(CurrentX-1,CurrentY).

// Predict the exact one-step result of move_towards(Current->Resume) for all relative directions.
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX < ResumeX  & CurrentY < ResumeY  <- PredictedX = CurrentX+1; PredictedY = CurrentY+1. // down-right
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX < ResumeX  & CurrentY > ResumeY  <- PredictedX = CurrentX+1; PredictedY = CurrentY-1. // up-right
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX < ResumeX  & CurrentY == ResumeY <- PredictedX = CurrentX+1; PredictedY = CurrentY.   // right
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX > ResumeX  & CurrentY < ResumeY  <- PredictedX = CurrentX-1; PredictedY = CurrentY+1. // down-left
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX > ResumeX  & CurrentY > ResumeY  <- PredictedX = CurrentX-1; PredictedY = CurrentY-1. // up-left
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX > ResumeX  & CurrentY == ResumeY <- PredictedX = CurrentX-1; PredictedY = CurrentY.   // left
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX == ResumeX & CurrentY < ResumeY  <- PredictedX = CurrentX;   PredictedY = CurrentY+1. // down
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX == ResumeX & CurrentY > ResumeY  <- PredictedX = CurrentX;   PredictedY = CurrentY-1. // up
+!predict_step(ResumeX,ResumeY,PredictedX,PredictedY) : pos(hero,CurrentX,CurrentY) & CurrentX == ResumeX & CurrentY == ResumeY <- PredictedX = CurrentX;   PredictedY = CurrentY.   // at target
