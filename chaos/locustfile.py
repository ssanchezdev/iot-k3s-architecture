from locust import HttpUser, task, between
import random

class IoTDeviceSimulator(HttpUser):
    #Simula que cada sensor envía un dato, espera entre 0.1 y 1 seg. y vuelve a enviar (spam)
    wait_time = between(0.1, 1.0)

    @task
    def send_telemetry(self):
        #Genera data falsa como si fuera de un sensor real
        payload = {
            "device_id": f"sensor-{random.randint(1000, 9999)}",
            "cpu_temperature": random.uniform(30.0, 85.0)
        }
        #Dispara al endpoint
        self.client.post("/api/v1/telemetry", json=payload)