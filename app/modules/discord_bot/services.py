from app.modules.discord_bot.repositories import DiscordBotRepository
from core.services.BaseService import BaseService


class DiscordBotService(BaseService):
    def __init__(self):
        super().__init__(DiscordBotRepository())
