# 내가이해한 빌더스테이지란 정말 빌드에 필요한 설정(config)파일만 필요하고  배포(production)스테이지 에서는 빌드에 필요한 파일이 없어도 되었다고 생각했다.
# 따라서 빌더 스테이지에 필요한것을 꼽아보자면 빌드에 필요한 소스코드 그리고 빌드에 필요한 설정파일 이었다.
# 배포 환경에서 필요한것은 production stage에 필요한 소스코드, 필요한 디펜던시의 정보를 가지고있는 package.json이었다.
# 빌더 스테이지에서 이미 필요한 내용을 빌드했고 그 빌드한 내용은 dist라는 폴더안에 담아두었기 때문에 tsconfig 가 필요없다고 생각했지만 계속 tsconfig를 달라고 에러를 뱉었다.
# 도커 멀티스테이지를 설정함에 있어서 미스가 있었던건지 아니면 애초에 각 스테이지별 이해가 잘못되었던건지 그도 아니면 빌드 라는 개념에 대해서 잘못알고있었던건지 많은 시도를 해보았지만 결국 더 헤깔리는 결과만 남았다...

#  도커 멀티스테이지를 설정하면서 만났던 가장커다란 에러 2개
#  1. npm(yarn) command not found. 개인적으로 이거 해결이 너무 어려웠다. 가장 기본적인 에러여서 그냥 문제가 무엇일까 라는 추측은 어렵지 않았다. nodejs이미지를 받아오지 못한게 가장 큰 문제였겠지..? 
#  왜냐면 npm이나 yarn은 기본적으로 nodejs안에 존재하는 디펜던시관리 패키지니까. 근데 가장 기본적이면서도 가장큰 문제인것은 나는 nodejs를 넣어주었는걸...? 왜 이런 에러를 뱉어내는지 이해하기 쉽지않았다. 

#  2. 프로덕션 레벨에서 빌드까지만 해놓고 컨테이너 안에 들어가본결과 node_modules가 비어있다. ...? yarn install해줬는데..? 그래서 nest라는 명령어가 아예안먹음
#  컨테이너 들어가서 npm install, yarn install 다해봤지만 일단 뭘받아지는 척은 하는데 nest라는 기본명령어가 안먹힘(당연하지... node_modules가 비었다니까...)

# 빡쳐서 멀티스테이지 없으면 어느정도 해결됨... 
  

FROM node:16-alpine as builder
WORKDIR /app
COPY package.json .
COPY ./yarn.lock ./
COPY tsconfig.json .
COPY ./src ./src
RUN yarn install --frozen-lockfile
RUN yarn build
RUN echo "builder stage"
# CMD yarn start

FROM node:16-alpine
WORKDIR /deploy
COPY ./tsconfig.json ./
COPY ./package.json ./
COPY ./yarn.lock ./
COPY ./src ./src
RUN yarn install --frozen-lockfile --production
COPY --from=builder /app/dist /deploy/dist 
RUN echo "안녕하심까??"
ENV NODE_ENV=production
EXPOSE 3000
CMD yarn start
