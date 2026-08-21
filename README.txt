C.P MotionSensor v1.0.4

eWeLink MS01 Zigbee 모션 센서를 위한 SmartThings Edge 드라이버입니다. 감지 신호의 소프트웨어 디바운스와 미감지 전환 시간을 세밀하게 설정할 수 있습니다.

지원 기기
- manufacturer: eWeLink
- model: MS01

주요 기능
- IAS Zone의 ZoneStatus 속성과 ZoneStatusChangeNotification으로 움직임 감지
- 배터리 상태와 수동 refresh 지원
- 감지 주기: 0.1~3600초
- 미감지 주기: 0.1~3600초
- 새 감지 수신 시 미감지 타이머 연장 여부 선택
- 감지 중 설정이 바뀌면 새 미감지 주기로 타이머 재설정
- Driver Information에 제작자와 버전 표시

동작 설명
- 감지 주기는 들어오는 움직임 보고를 처리할 최소 간격인 소프트웨어 디바운스입니다.
- 이 값을 짧게 설정해도 물리 센서의 하드웨어 전송 주기보다 빠르게 보고하게 만들 수는 없습니다.
- 감지 시 미감지 시간 연장을 켜면 처리된 감지마다 타이머를 다시 시작합니다.
- 연장을 끄면 최초 감지로 시작한 타이머를 이후 감지가 연장하지 않습니다.

설치
1. 압축을 풉니다.
2. SETUP-AND-INSTALL.cmd를 실행합니다.

드라이버 정보
- 제작자: 치즈가루
- 버전: v1.0.4
- packageKey: cheesepowder.ewelink-ms01-motion
