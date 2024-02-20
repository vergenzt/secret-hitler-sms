# Serverless Architecture



- Lambda functions for actions
- Static HTML frontend for gameplay
  - "Create new game"
    - POST /game
    - → gives code for people to join
  - "New player"
    - → asks for name & phone
    - POST /game/{code}/player/{phone}
    - → sends SMS to phone, requesting reply with "yes" to confirm participation
    - → sends update to SNS topic for browers to update their data
    - responses → POST /game/{code}/player/{phone}/reply
      - sets player verification status to true
      - → sends update to SNS topic for browers to update their data
  - "Join a game"
    - → asks for code
    - → asks for name & phone
    - POST /game/{code}/player (same as above)
  - "Start game"
    - POST /game/{code}/start
      - only host can start game (if not started, and only if all players verified)
      - initializes deck & player roles
      - sends player roles/parties to each player by SMS
  - "Legislate"
    - POST /game/{code}/legislate
      - only host can kick off legislative session
      - choose 



- Misc notes:
  - "log messages" are streamed along the bottom of the game