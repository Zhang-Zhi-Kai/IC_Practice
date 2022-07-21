import cv2
import matplotlib.pyplot as plt

test = [140,160]
original = [298,560]
plt.text(test[0], test[1], f"({test[0]},{test[1]})",fontsize=14)
total = [[755,510],[982,280],[710,50],[103,50],[103,340]]

for i in total:
    plt.plot([original[0],i[0]],[original[1],i[1]])
    plt.text(i[0], i[1], f"({i[0]},{i[1]})",fontsize=14)

plt.show()



