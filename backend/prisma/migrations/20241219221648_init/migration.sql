-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('ADMINISTRATOR', 'USER');

-- CreateEnum
CREATE TYPE "EntityType" AS ENUM ('PREFEITURA', 'CAMARA', 'AGUA', 'PREVIDENCIA', 'SAUDE', 'ENSINO', 'CONSORCIO', 'OUTROS');

-- CreateEnum
CREATE TYPE "CallOrigin" AS ENUM ('WHATSAPP', 'PHONE', 'MAIL');

-- CreateEnum
CREATE TYPE "TicketStatus" AS ENUM ('OPEN', 'CLOSE');

-- CreateEnum
CREATE TYPE "TicketMovimentType" AS ENUM ('PROGRAMACAO', 'AGUARDANDO', 'RETORNO', 'FINALIZACAO');

-- CreateTable
CREATE TABLE "Entity" (
    "id" VARCHAR(36) NOT NULL,
    "type" "EntityType" NOT NULL,
    "shortName" TEXT NOT NULL,
    "fullname" TEXT NOT NULL,

    CONSTRAINT "Entity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EntityClient" (
    "id" SERIAL NOT NULL,
    "clientId" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "dafault" BOOLEAN NOT NULL,

    CONSTRAINT "EntityClient_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Client" (
    "id" VARCHAR(36) NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "obs" TEXT,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "System" (
    "systemId" TEXT NOT NULL,
    "systemName" TEXT NOT NULL,

    CONSTRAINT "System_pkey" PRIMARY KEY ("systemId")
);

-- CreateTable
CREATE TABLE "Notebook" (
    "phoneoremail" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Notebook_pkey" PRIMARY KEY ("phoneoremail")
);

-- CreateTable
CREATE TABLE "Call" (
    "id" VARCHAR(36) NOT NULL,
    "senderId" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "begin" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "end" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "origin" "CallOrigin" NOT NULL,

    CONSTRAINT "Call_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CallMensage" (
    "id" VARCHAR(36) NOT NULL,
    "callId" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "sended" BOOLEAN NOT NULL,
    "mediaName" TEXT NOT NULL,
    "mediaHash" TEXT NOT NULL,
    "follow" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CallMensage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Ticket" (
    "id" VARCHAR(36) NOT NULL,
    "description" TEXT NOT NULL,
    "status" "TicketStatus" NOT NULL DEFAULT 'OPEN',
    "openAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdBy" TEXT NOT NULL,
    "originCall" TEXT NOT NULL,

    CONSTRAINT "Ticket_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TicketMovement" (
    "id" BIGSERIAL NOT NULL,
    "ticketId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "originCall" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "type" "TicketMovimentType" NOT NULL,

    CONSTRAINT "TicketMovement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InternalProcess" (
    "id" BIGSERIAL NOT NULL,
    "ticketId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),

    CONSTRAINT "InternalProcess_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" VARCHAR(36) NOT NULL,
    "username" TEXT NOT NULL,
    "fullname" TEXT NOT NULL,
    "nickname" TEXT,
    "passwordHash" TEXT NOT NULL,
    "passwordSalt" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastRequest" TIMESTAMP(3) NOT NULL,
    "email" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'USER',
    "systems" TEXT[],

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "EntityClient_clientId_idx" ON "EntityClient"("clientId");

-- CreateIndex
CREATE UNIQUE INDEX "EntityClient_clientId_entityId_key" ON "EntityClient"("clientId", "entityId");

-- CreateIndex
CREATE UNIQUE INDEX "Ticket_originCall_key" ON "Ticket"("originCall");

-- CreateIndex
CREATE UNIQUE INDEX "TicketMovement_originCall_key" ON "TicketMovement"("originCall");

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- AddForeignKey
ALTER TABLE "EntityClient" ADD CONSTRAINT "EntityClient_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EntityClient" ADD CONSTRAINT "EntityClient_entityId_fkey" FOREIGN KEY ("entityId") REFERENCES "Entity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Call" ADD CONSTRAINT "Call_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "Notebook"("phoneoremail") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Call" ADD CONSTRAINT "Call_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Call" ADD CONSTRAINT "Call_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CallMensage" ADD CONSTRAINT "CallMensage_callId_fkey" FOREIGN KEY ("callId") REFERENCES "Call"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ticket" ADD CONSTRAINT "Ticket_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ticket" ADD CONSTRAINT "Ticket_originCall_fkey" FOREIGN KEY ("originCall") REFERENCES "Call"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketMovement" ADD CONSTRAINT "TicketMovement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketMovement" ADD CONSTRAINT "TicketMovement_originCall_fkey" FOREIGN KEY ("originCall") REFERENCES "Call"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketMovement" ADD CONSTRAINT "TicketMovement_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "Ticket"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InternalProcess" ADD CONSTRAINT "InternalProcess_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
